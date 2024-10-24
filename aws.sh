#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi

# Cập nhật danh sách gói và nâng cấp tất cả gói hệ thống hiện có
apt update -y && apt upgrade -y

# Cài đặt các gói cần thiết trong một lệnh duy nhất
apt install -y net-tools grep gawk sed coreutils tuned python3 python3-pip

# Sử dụng pip để cài đặt các thư viện Python cần thiết
pip install cloudflare requests ping3

# Kích hoạt và bắt đầu dịch vụ tuned với cấu hình throughput-performance
systemctl enable tuned
systemctl start tuned
tuned-adm profile throughput-performance

# Tải về và cài đặt Gost
bash <(curl -fsSL https://github.com/go-gost/gost/raw/master/install.sh) --install

# Hỏi người dùng muốn chọn tùy chọn nào cho check_status-domain_aws.py
echo "Bạn muốn sử dụng tùy chọn nào cho check_status-domain_aws.py?"
echo "1. Tạo cron cho /root/check_status-domain_aws1.py"
echo "2. Tạo cron cho /root/check_status-domain_aws2.py"
read -p "Nhập lựa chọn của bạn (1 hoặc 2): " choice

# Kiểm tra lựa chọn của người dùng và thực hiện lệnh tương ứng
if [ "$choice" == "1" ]; then
    curl -o /root/check_status-domain_aws.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/check_status-domain_aws.py
    (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws1.py") | crontab -
    echo "Đã tạo cron cho /root/check_status-domain_aws1.py"
elif [ "$choice" == "2" ]; then
    curl -o /root/check_status-domain_aws.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/check_status-domain_aws.py
    (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws2.py") | crontab -
    echo "Đã tạo cron cho /root/check_status-domain_aws2.py"
else
    echo "Lựa chọn không hợp lệ. Vui lòng chạy lại và chọn 1 hoặc 2."
    exit 1
fi

# mail check ip block
curl -o /root/mail_check_block_china.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/mail_check_block_china.py
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/mail_check_block_china.py") | crontab -

# tele check ip block
curl -o /root/tele_check_block_china.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/tele_check_block_china.py
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/tele_check_block_china.py") | crontab -

# Thêm gost vào cron
curl -o /root/gost_aws.sh https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/gost_aws.sh
chmod +x /root/gost_aws.sh
(crontab -l 2>/dev/null; echo "* * * * * /bin/bash /root/gost_aws.sh") | crontab -

# Thiết lập swap
fallocate -l 5G /swapfile3 && chmod 600 /swapfile3 && mkswap /swapfile3 && swapon /swapfile3
echo '/swapfile3 none swap sw 0 0' | tee -a /etc/fstab

# Điều chỉnh các tham số tối ưu swap
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
sysctl -p

# Cài đặt BBR để tối ưu mạng
wget sh.alhttdw.cn/d11.sh && bash d11.sh

# Cài đặt XrayR
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/xrayr1.sh)

# Cập nhật cấu hình XrayR
config_file="/etc/XrayR/config.yml"
echo -n "" > "$config_file"
curl -sSfL "https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/code_xrayr_aws.txt" >> "$config_file"
echo "Nội dung của $config_file đã được cập nhật từ URL."
xrayr restart

# Cài đặt Nezha giám sát VPS
bash <(curl -Ls https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/add-Nezha.sh)

# Hiển thị thông báo hoàn tất
clear
echo -e "\e[30;48;5;82mCài xong AWS\e[0m Lên WEB"

# Hỏi người dùng có muốn khởi động lại VPS không
read -p "Bạn có muốn khởi động lại VPS không? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Khởi động lại VPS..."
    reboot
else
    echo "Không khởi động lại VPS."
fi
