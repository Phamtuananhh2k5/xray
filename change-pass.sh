#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/change_ssh_port.log"
SSH_CONFIG="/etc/ssh/sshd_config"
FAIL2BAN_JAIL="/etc/fail2ban/jail.local"
NEW_PORT=50022

# SMTP config
SMTP_HOST="smtp.phamanh.io.vn"
SMTP_PORT="587"
SMTP_USERNAME="no-reply@phamanh.io.vn"
SMTP_PASSWORD="Z9C3RFB2tUGN"
SMTP_FROM="no-reply@phamanh.io.vn"

# Ensure root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script với quyền root (sudo)." 
   exit 1
fi

update_system() {
    echo "[*] Cập nhật hệ thống và cài đặt các gói cần thiết..." | tee -a "$LOG"
    apt update -y && apt upgrade -y
    apt install -y net-tools grep gawk sed coreutils tuned python3 python3-pip msmtp
    apt autoremove -y
}

remove_old_ssh() {
    echo "[*] Gỡ openssh-server và xóa cấu hình cũ..." | tee -a "$LOG"
    systemctl stop ssh.socket || true
    systemctl disable ssh.socket || true
    apt purge -y openssh-server
    rm -rf /etc/ssh ~/.ssh
}

install_ssh() {
    echo "[*] Cài openssh-server..." | tee -a "$LOG"
    apt install -y openssh-server
}

configure_ssh() {
    echo "[*] Cấu hình SSH..." | tee -a "$LOG"
    cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSH_CONFIG"
    echo "root:Hoilamgi@12345" | chpasswd
}

install_fail2ban() {
    echo "[*] Cài đặt Fail2ban nếu chưa có..." | tee -a "$LOG"
    if ! dpkg -l | grep -qw fail2ban; then
        apt install -y fail2ban
    fi
}

configure_fail2ban() {
    echo "[*] Cấu hình Fail2ban..." | tee -a "$LOG"
    [ -f "$FAIL2BAN_JAIL" ] && cp "$FAIL2BAN_JAIL" "${FAIL2BAN_JAIL}.bak"
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

change_ssh_port() {
    echo "[*] Đổi cổng SSH sang $NEW_PORT..." | tee -a "$LOG"
    grep -q "^#\?Port" "$SSH_CONFIG" \
        && sed -i "s/^#\?Port .*/Port $NEW_PORT/" "$SSH_CONFIG" \
        || echo "Port $NEW_PORT" >> "$SSH_CONFIG"
}

restart_services() {
    echo "[*] Khởi động lại SSH & Fail2ban..." | tee -a "$LOG"
    systemctl daemon-reload
    systemctl restart ssh
    systemctl restart fail2ban
}

configure_msmtp() {
    echo "[*] Cấu hình msmtp..." | tee -a "$LOG"
    apt install -y msmtp msmtp-mta

    if [ -f /etc/msmtprc ]; then
        TIMESTAMP=$(date +%s)
        mv /etc/msmtprc "/etc/msmtprc.bak.$TIMESTAMP"
    fi

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
    echo "→ Cấu hình msmtp xong. In 20 dòng đầu:" | tee -a "$LOG"
    sed -n '1,20p' /etc/msmtprc
}

# Main execution
update_system
remove_old_ssh
install_ssh
configure_ssh
install_fail2ban
configure_fail2ban
change_ssh_port
restart_services
configure_msmtp

echo "[*] ✅ HOÀN TẤT – SSH đã đổi sang cổng $NEW_PORT" | tee -a "$LOG"
echo "[+] Mật khẩu root: Hoilamgi@12345" | tee -a "$LOG"
