#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi

# Update and install required packages
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y net-tools grep gawk sed coreutils tuned 

sudo systemctl enable tuned && sudo systemctl start tuned && sudo tuned-adm profile throughput-performance


bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/change-pass.sh)
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/crontab.sh)

bash <(curl -s https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/anti-ddos-ipv4.sh)


# add bbr 
wget sh.alhttdw.cn/d11.sh && bash d11.sh


# dowload cloudflare-ddns
sudo snap refresh && sudo snap install cloudflare-ddns
# config cloudflare-ddns
sudo snap run cloudflare-ddns -e dcmnmmmchkh@gmail.com -k 3b411374ee6b120fbfc87be4b80e930922034 -u az.rauxanh.site -4 $(curl -s ipinfo.io/ip) >> /root/ipcf.log 



# Cài xrayr 
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/xrayr1.sh)

# Đường dẫn tới tệp cấu hình XrayR
config_file="/etc/XrayR/config.yml"

# Xóa nội dung của tệp cấu hình
echo -n "" > "$config_file"

# Lấy nội dung từ URL và thêm vào tệp cấu hình
curl -sSfL "https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/code_xrayr_az.txt" >> "$config_file"

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
