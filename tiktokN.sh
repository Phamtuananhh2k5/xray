#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi

# thay pass
bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/change-pass.sh)
bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/gost-warp.sh)
# update 
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y nano wget curl

# auto warps
bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/auto-warp-cli.sh)


# add bbr 
wget sh.alhttdw.cn/d11.sh && bash d11.sh

# Xóa thư mục cài đặt
sudo rm -rf /usr/local/bin/cloudflare-ddns

# Xóa thư mục git đã sao chép
rm -rf ~/cloudflare-ddns-client

# Xóa tài khoản cấu hình cloudflare-ddns
rm -rf ~/.cloudflare-ddns

# Xóa tệp cấu hình tùy chọn nếu có
rm -f ~/.cloudflare-ddns-config

# Clone repository và kiểm tra lỗi
git clone https://github.com/LINKIWI/cloudflare-ddns-client.git && cd cloudflare-ddns-client || {
    echo "Lỗi khi clone repository. Kiểm tra kết nối mạng của bạn."
    exit 1
}

# Cập nhật gói và cài đặt phụ thuộc
apt update -y && apt install -y python-is-python3 python3-pip expect || {
    echo "Lỗi cài đặt các gói phụ thuộc. Kiểm tra kết nối mạng và quyền của bạn."
    exit 1
}

# Cài đặt cloudflare-ddns-client
make install || {
    echo "Lỗi trong quá trình cài đặt cloudflare-ddns-client."
    exit 1
}

# Cấu hình thông tin CloudFlare DDNS
cloudflare-ddns --configure << EOF
K
dcmnmmmchkh@gmail.com
3b411374ee6b120fbfc87be4b80e930922034
sv.dualeovpn.net
EOF

# Cài xrayr 
bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/xrayr1.sh)

# Đường dẫn tới tệp cấu hình XrayR
config_file="/etc/XrayR/config.yml"

# Xóa nội dung của tệp cấu hình
echo -n "" > "$config_file"

# Lấy nội dung từ URL và thêm vào tệp cấu hình
curl -sSfL "https://raw.githubusercontent.com/Panhuqusyxh/xray/main/code-xrayr-tiktok.txt" >> "$config_file"

# Kết thúc thông báo
echo "Nội dung của $config_file đã được cập nhật từ URL."
xrayr restart
clear
# add vps lên vps.dualeovpn.net

bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/add-Nezha.sh)
  
# Thực hiện cập nhật DDNS ngay lập tức
cloudflare-ddns --update-now

clear 
echo -e "\e[30;48;5;82mCài xong TIKTOK\e[0m Lên WEB"
