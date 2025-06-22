#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/change_ssh_port.log"
LOCK="/tmp/.change_ssh_port.lock"
INFO_FILE="/root/ssh_info.txt"
SSH_CONFIG="/etc/ssh/sshd_config"
FAIL2BAN_JAIL="/etc/fail2ban/jail.local"
NEW_PORT=50022
DEFAULT_PASSWORD="Hoilamgi@12345"

# SMTP
SMTP_HOST="smtp.phamanh.io.vn"
SMTP_PORT="587"
SMTP_USERNAME="no-reply@phamanh.io.vn"
SMTP_PASSWORD="Z9C3RFB2tUGN"
SMTP_FROM="no-reply@phamanh.io.vn"

# Lock check
if [[ -f "$LOCK" ]]; then
    echo "[!] Script đang chạy ở tiến trình khác. Thoát..."
    exit 1
fi
touch "$LOCK"
trap 'rm -f "$LOCK"' EXIT

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOG"
}

if [[ $EUID -ne 0 ]]; then
    log "Vui lòng chạy script với quyền root (sudo)."
    exit 1
fi

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID=$ID
    else
        log "Không thể xác định hệ điều hành."; exit 1
    fi
}

check_port_available() {
    if ss -tuln | grep -q ":$NEW_PORT "; then
        log "❌ Cổng $NEW_PORT đang bị sử dụng. Hủy thao tác."
        exit 1
    fi
}

remove_ssh() {
    log "Gỡ sạch SSH và xóa các tệp cấu hình liên quan..."

    case "$OS_ID" in
        ubuntu|debian)
            apt purge -y openssh-server openssh-client
            apt autoremove -y
            ;;
        centos|rhel|almalinux|rocky)
            yum remove -y openssh-server openssh-clients || dnf remove -y openssh-server openssh-clients || true
            ;;
    esac

    rm -rf /etc/ssh
    rm -f "$SSH_CONFIG" "${SSH_CONFIG}.bak"
}

install_packages() {
    log "Cài đặt các gói cần thiết..."
    case "$OS_ID" in
        ubuntu|debian)
            export DEBIAN_FRONTEND=noninteractive
            apt update -y
            apt install -y net-tools grep gawk sed coreutils tuned python3 python3-pip fail2ban openssh-server msmtp msmtp-mta ca-certificates curl
            apt autoremove -y
            ;;
        centos|rhel)
            yum install -y epel-release
            yum install -y net-tools grep gawk sed coreutils tuned python3 python3-pip fail2ban openssh-server msmtp curl ca-certificates
            ;;
        almalinux|rocky)
            dnf install -y epel-release
            dnf install -y net-tools grep gawk sed coreutils tuned python3 python3-pip fail2ban openssh-server msmtp curl ca-certificates
            ;;
        *)
            log "Không hỗ trợ hệ điều hành: $OS_ID"; exit 1
            ;;
    esac

    if [ ! -f /etc/ssl/certs/ca-certificates.crt ]; then
        update-ca-certificates || log "Không thể cập nhật CA certificates"
    fi
}

configure_ssh() {
    log "Sao lưu cấu hình SSH..."
    cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"
    cp -r /etc/ssh "/etc/ssh.backup.$(date +%F_%H%M%S)"

    log "Cấu hình SSH..."
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSH_CONFIG"
    grep -q "^#\?Port" "$SSH_CONFIG" \
        && sed -i "s/^#\?Port .*/Port $NEW_PORT/" "$SSH_CONFIG" \
        || echo "Port $NEW_PORT" >> "$SSH_CONFIG"

    echo "root:$DEFAULT_PASSWORD" | chpasswd
}

configure_fail2ban() {
    log "Cấu hình Fail2ban..."
    mkdir -p "$(dirname "$FAIL2BAN_JAIL")"
    cp "$FAIL2BAN_JAIL" "${FAIL2BAN_JAIL}.bak" 2>/dev/null || true

    tee "$FAIL2BAN_JAIL" > /dev/null << EOF
[DEFAULT]
sender = $SMTP_FROM
destemail = me@phamanh.io.vn, dcmnmmmchkh@gmail.com
action = %(action_mwl)s

[sshd]
enabled = true
port    = $NEW_PORT
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 5
findtime = 36000
bantime = 604800
EOF
}

configure_msmtp() {
    log "Cấu hình msmtp..."
    tee /etc/msmtprc > /dev/null <<EOF
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auto_from      off

account phamanh
host     ${SMTP_HOST}
port     ${SMTP_PORT}
auth     on
user     ${SMTP_USERNAME}
password ${SMTP_PASSWORD}
from     ${SMTP_FROM}

account default : phamanh
EOF

    chmod 600 /etc/msmtprc
}

restart_services() {
    log "Kiểm tra cấu hình SSH..."
    mkdir -p /run/sshd  # Fix lỗi thiếu thư mục khi cài mới

    sshd -t || {
        log "❌ Lỗi cấu hình SSH. Rollback."
        cp "${SSH_CONFIG}.bak" "$SSH_CONFIG"
        systemctl restart ssh || true
        exit 1
    }

    SSH_SERVICE=$(systemctl list-units --type=service | grep -q "sshd.service" && echo "sshd" || echo "ssh")

    if ! systemctl restart "$SSH_SERVICE"; then
        log "❌ Restart SSH lỗi. Rollback."
        cp "${SSH_CONFIG}.bak" "$SSH_CONFIG"
        systemctl restart "$SSH_SERVICE" || true
        exit 1
    fi

    systemctl restart fail2ban || true
}

save_info_file() {
    PUBLIC_IP=$(curl -s https://api.ipify.org || echo "<Không lấy được IP>")
    log "Ghi thông tin SSH tại $INFO_FILE"
    {
        echo "SSH PORT: $NEW_PORT"
        echo "ROOT PASSWORD: $DEFAULT_PASSWORD"
        echo "Đăng nhập: ssh root@$PUBLIC_IP -p $NEW_PORT"
        echo "Generated: $(date)"
    } > "$INFO_FILE"

    log "Đăng nhập SSH: ssh root@$PUBLIC_IP -p $NEW_PORT"
}

send_log_email() {
    log "Gửi log qua email..."
    cat "$LOG" | msmtp me@phamanh.io.vn
}

warn_default_password() {
    if grep -q "$DEFAULT_PASSWORD" "$INFO_FILE"; then
        log "⚠️ Bạn vẫn đang sử dụng mật khẩu mặc định ($DEFAULT_PASSWORD). NÊN ĐỔI NGAY!"
    fi
}

# MAIN
detect_os
check_port_available
remove_ssh
install_packages
configure_ssh
configure_fail2ban
configure_msmtp
restart_services
save_info_file
send_log_email
warn_default_password

log "✅ HOÀN TẤT – SSH đã đổi sang cổng $NEW_PORT"
