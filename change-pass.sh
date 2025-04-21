#!/bin/bash

LOG="/var/log/change_ssh_port.log"
SSH_CONFIG="/etc/ssh/sshd_config"
FAIL2BAN_JAIL="/etc/fail2ban/jail.local"
NEW_PORT=50022

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script với quyền root (sudo)." 
   exit 1
fi

# Hàm cập nhật hệ thống và cài đặt các gói cần thiết
update_system() {
    echo "[*] Cập nhật hệ thống và cài đặt các gói cần thiết..." | tee -a $LOG
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y net-tools grep gawk sed coreutils tuned python3 python3-pip msmtp
    sudo apt autoremove -y
}

# Hàm gỡ bỏ openssh-server và xóa cấu hình cũ
remove_old_ssh() {
    echo "[*] Gỡ bỏ openssh-server và xóa cấu hình cũ..." | tee -a $LOG
    sudo apt purge -y openssh-server
    sudo rm -rf /etc/ssh
    sudo rm -rf ~/.ssh
}

# Hàm cài đặt lại SSH
install_ssh() {
    echo "[*] Cài đặt lại openssh-server..." | tee -a $LOG
    sudo apt install -y openssh-server
}

# Hàm cấu hình SSH cho phép đăng nhập root và thay đổi mật khẩu
configure_ssh() {
    echo "[*] Đang cấu hình SSH..." | tee -a $LOG
    sudo cp $SSH_CONFIG ${SSH_CONFIG}.bak
    sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' $SSH_CONFIG
    sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' $SSH_CONFIG
    echo "root:Hoilamgi@12345" | sudo chpasswd
}

# Hàm cấu hình Fail2ban
configure_fail2ban() {
    echo "[*] Cấu hình Fail2ban..." | tee -a $LOG
    if [ -f $FAIL2BAN_JAIL ]; then
        sudo cp $FAIL2BAN_JAIL ${FAIL2BAN_JAIL}.bak
    fi
    sudo tee $FAIL2BAN_JAIL > /dev/null << EOF
[DEFAULT]
sender = no-reply@phamanh.io.vn
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

# Hàm khởi động lại dịch vụ SSH và Fail2ban
restart_services() {
    echo "[*] Khởi động lại các dịch vụ SSH và Fail2ban..." | tee -a $LOG
    sudo systemctl restart ssh
    sudo systemctl restart fail2ban
}

# Hàm thay đổi cổng SSH và cấu hình lại Fail2ban
change_ssh_port() {
    echo "[*] Đang thay đổi cổng SSH sang $NEW_PORT..." | tee -a $LOG
    # Thay đổi cổng trong SSH config
    if grep -q "^#Port" $SSH_CONFIG; then
        sudo sed -i "s/^#Port .*/Port $NEW_PORT/" $SSH_CONFIG
    elif grep -q "^Port" $SSH_CONFIG; then
        sudo sed -i "s/^Port .*/Port $NEW_PORT/" $SSH_CONFIG
    else
        echo "Port $NEW_PORT" | sudo tee -a $SSH_CONFIG
    fi
    echo "[+] Đã cập nhật cổng SSH thành $NEW_PORT" | tee -a $LOG
}

# Hàm kiểm tra và cài đặt Fail2ban
install_fail2ban() {
    echo "[*] Kiểm tra và cài đặt Fail2ban..." | tee -a $LOG
    if ! dpkg -l | grep -qw fail2ban; then
        sudo apt install -y fail2ban
    fi
}

# Main script
update_system
remove_old_ssh
install_ssh
configure_ssh
install_fail2ban
configure_fail2ban
change_ssh_port
restart_services

echo "[*] ✅ HOÀN TẤT – Hãy kiểm tra SSH mới bằng: ssh -p $NEW_PORT user@your_ip" | tee -a $LOG
echo "[+] Mật khẩu root đã được thay đổi và SSH đã được cấu hình lại thành công thành: Hoilamgi@12345"
