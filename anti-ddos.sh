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


sudo curl -o /etc/anti-ddos/check-ddos.sh https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/anti-ddos.txt
sudo chmod +x /etc/anti-ddos/check-ddos.sh


# Tạo thư mục nếu chưa tồn tại
mkdir -p /etc/anti-ddos

# Tạo và ghi nội dung vào file /etc/anti-ddos/run_check_ddos.sh
cat << 'EOF' > /etc/anti-ddos/run_check_ddos.sh
#!/bin/bash

while true; do
    /etc/anti-ddos/check-ddos.sh
    sleep 1
done
EOF

# Đặt quyền thực thi cho script
chmod +x /etc/anti-ddos/run_check_ddos.sh

# Tạo và ghi nội dung vào file service systemd
cat << 'EOF' > /etc/systemd/system/check-ddos.service
[Unit]
Description=Check DDoS Script
After=network.target

[Service]
ExecStart=/etc/anti-ddos/run_check_ddos.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Khởi động và kích hoạt service
systemctl start check-ddos.service
systemctl enable check-ddos.service

