#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/change-pass.sh)
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/crontab.sh)

bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/gost-out.sh)

# update 
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y nano wget curl
# thay pass
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/change-pass.sh)
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
REMOVED
3.thanhtong.top,aws.dualeovpn.net
EOF



# Cài xrayr 
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/xrayr1.sh)

# Đường dẫn tới tệp cấu hình XrayR
config_file="/etc/XrayR/config.yml"

# Xóa nội dung của tệp cấu hình
echo -n "" > "$config_file"

# Lấy nội dung từ URL và thêm vào tệp cấu hình
curl -sSfL "https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/80.txt" >> "$config_file"

# Kết thúc thông báo
echo "Nội dung của $config_file đã được cập nhật từ URL."
xrayr restart
clear
/root/ddos-deflate-master/uninstall.sh
rm -rf /usr/local/ddos
rm /usr/local/sbin/ddos
rm /etc/cron.d/ddos

sudo apt install dnsutils && sudo apt-get install net-tools && sudo apt-get install tcpdump && sudo apt-get install dsniff -y && sudo apt install grepcidr	

wget https://github.com/jgmdev/ddos-deflate/archive/master.zip -O ddos.zip && unzip ddos.zip && cd ddos-deflate-master && ./install.sh	

curl -o /etc/ddos/ddos.conf https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/ddos.conf && service ddos restart	

clear

# add vps lên vps.dualeovpn.net
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/add-Nezha.sh)

# Thực hiện cập nhật DDNS ngay lập tức
cloudflare-ddns --update-now

clear 
echo -e "\e[30;48;5;82mCài xong AZ\e[0m Lên WEB"
#!/bin/bash
# khởi động lại 
echo "Bạn có muốn khởi động lại VPS không? (nhấn Enter để đồng ý, n để hủy)"
read answer

if [ -z "$answer" ] || [ "$answer" == "y" ]; then
    echo "Khởi động lại VPS..."
    sudo reboot
else
    echo "Không khởi động lại VPS."
fi
