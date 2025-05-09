#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script với quyền root (sudo)." 
   exit 1
fi

# Chạy apt update với tùy chọn -y để đồng ý với tất cả các yêu cầu
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y net-tools grep gawk sed coreutils tuned && apt autoremove -y  

sudo apt install python3 python3-pip -y

# Gỡ cài đặt openssh-server với tùy chọn -y để đồng ý với tất cả các yêu cầu
sudo apt purge openssh-server -y

# Xóa toàn bộ thư mục /etc/ssh
sudo rm -rf /etc/ssh

# Xóa toàn bộ thư mục ~/.ssh của người dùng hiện tại
sudo rm -rf ~/.ssh

sudo apt update -y && sudo apt upgrade -y && sudo apt install -y net-tools grep gawk sed coreutils tuned && apt autoremove -y  

sudo apt install openssh-server -y

sudo apt install msmtp

sudo systemctl stop ssh.socket  && sudo systemctl disable ssh.socket


# Thay đổi mật khẩu root
echo "root:Hoilamgi@12345" | chpasswd

# Cấu hình SSH để cho phép đăng nhập root bằng mật khẩu
SSHD_CONFIG="/etc/ssh/sshd_config"

# Sao lưu file cấu hình hiện tại
cp $SSHD_CONFIG ${SSHD_CONFIG}.bak

# Chỉnh sửa file cấu hình
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' $SSHD_CONFIG
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' $SSHD_CONFIG
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' $SSHD_CONFIG
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' $SSHD_CONFIG

# Khởi động lại dịch vụ SSH
sudo systemctl restart ssh


# Kiểm tra trạng thái của dịch vụ SSH
sudo systemctl status ssh --no-pager

echo "Mật khẩu root đã được thay đổi và SSH đã được cấu hình lại thành công thành: Hoilamgi@12345"

# Hàm kiểm tra sự tồn tại của gói fail2ban (dành cho hệ thống Debian/Ubuntu)
function is_fail2ban_installed() {
    dpkg -l | grep -qw fail2ban
}

echo "Đang kiểm tra xem Fail2ban đã được cài đặt chưa..."

if is_fail2ban_installed; then
    echo "Fail2ban đã được cài đặt. Đang gỡ bỏ..."
    # Dừng dịch vụ nếu đang chạy
    systemctl stop fail2ban

    # Gỡ bỏ fail2ban và xoá các file cấu hình
    apt-get remove -y fail2ban
    apt-get purge -y fail2ban

    # Xóa các file cấu hình còn sót lại (nếu có)
    rm -rf /etc/fail2ban
else
    echo "Fail2ban chưa được cài đặt."
fi

echo "Cập nhật danh sách gói và cài đặt lại Fail2ban..."
apt-get update
apt-get install -y fail2ban

echo "Cấu hình bảo mật cho SSH thông qua Fail2ban..."

# Tạo file cấu hình jail.local cho Fail2ban. Nếu file đã tồn tại thì backup lại.
if [ -f /etc/fail2ban/jail.local ]; then
    cp /etc/fail2ban/jail.local /etc/fail2ban/jail.local.bak
    echo "Đã backup file cấu hình cũ sang /etc/fail2ban/jail.local.bak"
fi

# Ghi cấu hình mới cho SSH. (Lưu ý: logpath trên Ubuntu là /var/log/auth.log,
# trên CentOS có thể là /var/log/secure)
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
sender = no-reply@phamanh.io.vn
destemail = me@phamanh.io.vn, dcmnmmmchkh@gmail.com
action = %(action_mwl)s

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 5
findtime = 36000
bantime = 604800

EOF

echo "Khởi động lại dịch vụ Fail2ban..."
systemctl restart fail2ban

#!/usr/bin/env bash
set -euo pipefail

# Thông số SMTP của bạn
SMTP_HOST="smtp.phamanh.io.vn"
SMTP_PORT="587"
SMTP_USERNAME="no-reply@phamanh.io.vn"
SMTP_PASSWORD="Z9C3RFB2tUGN"
SMTP_FROM="no-reply@phamanh.io.vn"

# 1. Cập nhật và cài msmtp + msmtp-mta
sudo apt update
sudo apt install -y msmtp msmtp-mta

# 2. Backup file cũ nếu có
if [ -f /etc/msmtprc ]; then
  TIMESTAMP=$(date +%s)
  sudo mv /etc/msmtprc /etc/msmtprc.bak.$TIMESTAMP
  echo "→ Đã backup /etc/msmtprc thành /etc/msmtprc.bak.$TIMESTAMP"
fi

# 3. Tạo /etc/msmtprc mới theo đúng format yêu cầu
sudo tee /etc/msmtprc > /dev/null <<EOF
# /etc/msmtprc
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

# 4. Giới hạn quyền đọc file chỉ cho root
sudo chmod 600 /etc/msmtprc

echo "→ Đã cài đặt và cấu hình msmtp xong. 20 dòng đầu của /etc/msmtprc:"
sudo sed -n '1,20p' /etc/msmtprc


#!/bin/bash

# ==== CONFIG ====
NEW_PORT=50022
SSH_CONFIG="/etc/ssh/sshd_config"
FAIL2BAN_JAIL="/etc/fail2ban/jail.local"
LOG="/var/log/change_ssh_port.log"

echo "[*] Đang đổi SSH sang port $NEW_PORT..." | tee -a $LOG

# 1. Backup sshd_config
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"
echo "[+] Đã backup $SSH_CONFIG thành ${SSH_CONFIG}.bak" | tee -a $LOG

# 2. Đổi port trong sshd_config
if grep -q "^#Port" "$SSH_CONFIG"; then
    sed -i "s/^#Port .*/Port $NEW_PORT/" "$SSH_CONFIG"
elif grep -q "^Port" "$SSH_CONFIG"; then
    sed -i "s/^Port .*/Port $NEW_PORT/" "$SSH_CONFIG"
else
    echo "Port $NEW_PORT" >> "$SSH_CONFIG"
fi
echo "[+] Đã cập nhật port SSH thành $NEW_PORT" | tee -a $LOG

# 3. KHÔNG thay đổi logpath - vẫn là /var/log/auth.log

# 4. Cập nhật Fail2Ban - chỉ sửa đúng block [sshd] hoặc thêm nếu chưa có
if grep -q "^\[sshd\]" "$FAIL2BAN_JAIL"; then
    # Nếu block đã có, sửa port trong vùng từ [sshd] đến dòng [khác] hoặc hết file
    awk -v port="$NEW_PORT" '
        BEGIN { in_block = 0 }
        /^\[sshd\]/ { in_block = 1; print; next }
        /^\[.*\]/ && in_block { in_block = 0 }
        in_block && /^port[ \t]*=/ { print "port = " port; next }
        { print }
    ' "$FAIL2BAN_JAIL" > "${FAIL2BAN_JAIL}.tmp" && mv "${FAIL2BAN_JAIL}.tmp" "$FAIL2BAN_JAIL"
else
    echo -e "\n[sshd]\nport = $NEW_PORT\nlogpath = /var/log/auth.log" >> "$FAIL2BAN_JAIL"
fi
echo "[+] Đã cập nhật port Fail2Ban SSH" | tee -a $LOG

# 5. Restart dịch vụ
systemctl restart ssh && echo "[+] Đã restart SSHD" | tee -a $LOG
systemctl restart fail2ban && echo "[+] Đã restart Fail2Ban" | tee -a $LOG

# 6. Nhắc người dùng test lại
echo "[*] ✅ HOÀN TẤT – Hãy kiểm tra SSH mới bằng:" | tee -a $LOG
echo "    ssh -p $NEW_PORT user@your_ip" | tee -a $LOG


# Kiểm tra trạng thái của dịch vụ Fail2ban
sudo systemctl status fail2ban --no-pager

echo "Quá trình cài đặt và cấu hình Fail2ban cho SSH hoàn tất, Mật khẩu cho root là Hoilamgi@12345"
