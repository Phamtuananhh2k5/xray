#!/bin/bash
# Đường dẫn tới thư mục cần kiểm tra
DIR="/etc/anti-ddos"

# Kiểm tra nếu thư mục tồn tại
if [ -d "$DIR" ]; then
  echo "Directory $DIR already exists."
else
  # Tạo thư mục nếu chưa tồn tại
  mkdir -p "$DIR"
  echo "Directory $DIR created."
fi


sudo mkdir -p /etc/anti-ddos
sudo touch /etc/anti-ddos/check-ddos.sh
sudo chmod +x /etc/anti-ddos/check-ddos.sh
sudo chmod 777 /etc/anti-ddos/check-ddos.sh


