#!/bin/bash

# Chạy apt update với tùy chọn -y để đồng ý với tất cả các yêu cầu
sudo apt update -y
sudo apt install python3 python3-pip -y

# Gỡ cài đặt openssh-server với tùy chọn -y để đồng ý với tất cả các yêu cầu
sudo apt purge openssh-server -y

# Xóa toàn bộ thư mục /etc/ssh
sudo rm -rf /etc/ssh

# Xóa toàn bộ thư mục ~/.ssh của người dùng hiện tại
sudo rm -rf ~/.ssh

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
sudo systemctl status sshd

echo "Mật khẩu root đã được thay đổi và SSH đã được cấu hình lại thành công thành: Hoilamgi@12345."
