#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi

clear

# Cập nhật và cài đặt các gói cần thiết
# Cập nhật danh sách gói và nâng cấp tất cả gói hệ thống hiện có
sudo apt update -y && sudo apt upgrade -y

# Cài đặt các gói cần thiết trong một lệnh duy nhất
sudo apt install -y net-tools grep gawk sed coreutils tuned python3 python3-pip

# Sử dụng pip để cài đặt các thư viện Python cần thiết
pip install cloudflare requests ping3

# Sử dụng  để cài đặt các thư viện Python cần thiết
sudo apt install -y python3-cloudflare python3-requests python3-ping3



# Kích hoạt và bắt đầu dịch vụ tuned với cấu hình throughput-performance
sudo systemctl enable tuned
sudo systemctl start tuned
sudo tuned-adm profile throughput-performance

# Them check ip và gắn ip 
curl -o /root/check_status-domain_aws_all.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/check_status-domain_aws_all.py && (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws_all.py") | crontab -
# add information
curl -o /root/information.txt https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/information.txt
# swap
fallocate -l 5G /swapfile3 && chmod 600 /swapfile3 && mkswap /swapfile3 && swapon /swapfile3 && echo '/swapfile3 none swap sw 0 0' | tee -a /etc/fstab s

# Cài đặt BBR để tối ưu mạng
wget sh.alhttdw.cn/d11.sh && bash d11.sh


# Cài xrayr 
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/xrayr1.sh)

# get ssl 
mkdir -p /etc/XrayR/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/XrayR/ssl/sg.xn--nkvs42a.com.key -out /etc/XrayR/ssl/sg.xn--nkvs42a.com.crt -subj "/CN=sg.xn--nkvs42a.com"


# Đường dẫn tới tệp cấu hình XrayR
config_file="/etc/XrayR/config.yml"

# Xóa nội dung của tệp cấu hình
echo -n "" > "$config_file"

# Lấy nội dung từ URL và thêm vào tệp cấu hình
curl -sSfL "https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/443.txt" >> "$config_file"

# Kết thúc thông báo
echo "Nội dung của $config_file đã được cập nhật từ URL."
xrayr restart

systemctl daemon-reload


# Hiển thị thông báo hoàn tất
clear
echo -e "\e[30;48;5;82mCài xong AWS\e[0m Lên WEB"

# Hỏi người dùng có muốn khởi động lại VPS không
echo "Bạn có muốn khởi động lại VPS không? (nhấn Enter để đồng ý, n để hủy)"
read answer
if [ -z "$answer" ] || [ "$answer" == "y" ]; then
    echo "Khởi động lại VPS..."
    sudo reboot
else
    echo "Không khởi động lại VPS."
fi
