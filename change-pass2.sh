#!/bin/bash

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
systemctl restart sshd

# Kiểm tra trạng thái của dịch vụ SSH
systemctl status sshd

echo "Mật khẩu root đã được thay đổi và SSH đã được cấu hình lại thành công."
