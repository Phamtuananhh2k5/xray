#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi

# Cập nhật và cài đặt các gói cần thiết
# Cập nhật danh sách gói và nâng cấp tất cả gói hệ thống hiện có
sudo apt update -y && sudo apt upgrade -y

# Cài đặt các gói cần thiết trong một lệnh duy nhất
sudo apt install -y net-tools grep gawk sed coreutils tuned python3 python3-pip

# Sử dụng pip để cài đặt các thư viện Python cần thiết
pip install cloudflare requests ping3




# Kích hoạt và bắt đầu dịch vụ tuned với cấu hình throughput-performance
sudo systemctl enable tuned
sudo systemctl start tuned
sudo tuned-adm profile throughput-performance

# Thay đổi mật khẩu qua script từ GitHub
bash <(curl -Ls https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/change-pass.sh)

# Thiết lập crontab từ GitHub
bash <(curl -Ls https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/crontab2.sh)

# Chạy script chống DDoS
bash <(curl -s https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/anti-ddos-ipv4.sh)

#install wireguard
bash <(curl -L https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/install-wireguard.sh)

# Them check ip và gắn ip 
curl -o /root/check_status-domain.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/check_status-domain2.py && chmod +x /root/check_status-domain.py 


# Cài đặt BBR để tối ưu mạng
wget sh.alhttdw.cn/d11.sh && bash d11.sh


# Cài đặt XrayR và cập nhật cấu hình
bash <(curl -Ls https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/xrayr1.sh)
config_file="/etc/XrayR/config.yml"
echo -n "" > "$config_file"
curl -sSfL "https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/code-xrayr-tiktok.txt" >> "$config_file"
echo "Nội dung của $config_file đã được cập nhật từ URL."
xrayr restart

# Gỡ cài đặt và cài lại công cụ DDoS Deflate
/root/ddos-deflate-master/uninstall.sh
rm -rf /usr/local/ddos /usr/local/sbin/ddos /etc/cron.d/ddos
sudo apt install -y dnsutils net-tools tcpdump dsniff grepcidr
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip -O ddos.zip
unzip ddos.zip && cd ddos-deflate-master && ./install.sh
curl -o /etc/ddos/ddos.conf https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/ddos.conf
service ddos restart

# Thêm VPS lên hệ thống giám sát VPS
bash <(curl -Ls https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/add-Nezha.sh)


# Hiển thị thông báo hoàn tất
clear
echo -e "\e[30;48;5;82mCài xong AZ\e[0m Lên WEB"

# Hỏi người dùng có muốn khởi động lại VPS không
echo "Bạn có muốn khởi động lại VPS không? (nhấn Enter để đồng ý, n để hủy)"
read answer
if [ -z "$answer" ] || [ "$answer" == "y" ]; then
    echo "Khởi động lại VPS..."
    sudo reboot
else
    echo "Không khởi động lại VPS."
fi
