#!/bin/bash
sudo rm /etc/ssh/sshd_config

URL="https://raw.githubusercontent.com/Panhuqusyxh/xray/main/ssh_config.txt"
CONFIG_FILE="/etc/ssh/sshd_config"

# Kiểm tra xem tệp /etc/ssh/sshd_config đã tồn tại chưa
if [ -e "$CONFIG_FILE" ]; then
    # Nếu tệp đã tồn tại, tải nội dung từ URL và ghi vào tệp
    sudo curl -o "$CONFIG_FILE" "$URL"
    echo "File $CONFIG_FILE đã được cập nhật."
else
    # Nếu tệp chưa tồn tại, tạo mới và ghi nội dung từ URL vào đó
    sudo mkdir -p "$(dirname "$CONFIG_FILE")" && sudo curl -o "$CONFIG_FILE" "$URL"
    echo "File $CONFIG_FILE đã được tạo và cập nhật."
fi


# Thiết lập mật khẩu mới cho tài khoản root
echo "root:Hoilamgi@12345" | sudo chpasswd

echo "Mật khẩu của tài khoản root đã được thiết lập thành 'Hoilamgi@12345'."

# Khởi động lại dịch vụ SSH để áp dụng thay đổi
service ssh restart

echo "Đã cấp quyền SSH cho người dùng root và thay đổi mật khẩu thành công."
