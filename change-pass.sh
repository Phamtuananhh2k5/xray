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

# Kiểm tra trạng thái của dịch vụ Fail2ban
sudo systemctl status fail2ban --no-pager

echo "Quá trình cài đặt và cấu hình Fail2ban cho SSH hoàn tất, Mật khẩu cho root là Hoilamgi@12345"
