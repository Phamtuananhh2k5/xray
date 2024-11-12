#!/bin/bash

# Kiểm tra xem người dùng hiện tại có phải là root không
if [ "$EUID" -ne 0 ]; then
    echo "Bạn không đang ở root, hãy đăng nhập vào tài khoản root để thực hiện lệnh này."
    exit 1
fi

clear
# Hỏi người dùng về số AWS
while true; do
    read -p "Bạn đang chạy trên AWS số mấy? : " AWS_NUMBER
    if [[ "$AWS_NUMBER" =~ ^[1-8]$ ]]; then
        echo "Bạn đã chọn AWS số $AWS_NUMBER."
        break
    else
        echo "Vui lòng nhập số từ 1 đến 8."
    fi
done

# Lưu số AWS vào file
echo $AWS_NUMBER > /root/aws_number.txt

clear

# hệ thống giám sát VPS
bash <(curl -Ls https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/add-Nezha.sh)

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
# dowload gost
bash <(curl -fsSL https://github.com/go-gost/gost/raw/master/install.sh) --install

# Them check ip và gắn ip 
curl -o /root/check_status-domain_aws1.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/check_status-domain_aws1.py && (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws1.py") | crontab -
curl -o /root/check_status-domain_aws2.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/check_status-domain_aws2.py && (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws2.py") | crontab -
# mail check ip block
curl -o /root/mail_check_block_china.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/mail_check_block_china.py && (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/mail_check_block_china.py") | crontab -
# tele check ip block
curl -o /root/tele_check_block_china.py https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/tele_check_block_china.py && (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /root/tele_check_block_china.py") | crontab -
# thêm gost 
curl -o /root/gost_aws.sh https://raw.githubusercontent.com/Phamtuananhh2k5/xray/refs/heads/main/gost_aws.sh && chmod +x /root/gost_aws.sh && (crontab -l 2>/dev/null; echo "* * * * * /bin/bash /root/gost_aws.sh") | crontab -
# swap
fallocate -l 5G /swapfile3 && chmod 600 /swapfile3 && mkswap /swapfile3 && swapon /swapfile3 && echo '/swapfile3 none swap sw 0 0' | tee -a /etc/fstab s
# ghi crontab -e 
(crontab -l 2>/dev/null | grep -v '^\* \* \* \* \*' ; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws1.py"; echo "* * * * * /usr/bin/python3 /root/check_status-domain_aws2.py"; echo "* * * * * /usr/bin/python3 /root/mail_check_block_china.py"; echo "* * * * * /usr/bin/python3 /root/tele_check_block_china.py"; echo "* * * * * /bin/bash /root/gost_aws.sh") | crontab -


# Cài đặt BBR để tối ưu mạng
wget sh.alhttdw.cn/d11.sh && bash d11.sh


# Cài xrayr 
bash <(curl -Ls  https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/xrayr1.sh)

# Đường dẫn tới tệp cấu hình XrayR
config_file="/etc/XrayR/config.yml"

# Xóa nội dung của tệp cấu hình
echo -n "" > "$config_file"

# Lấy nội dung từ URL và thêm vào tệp cấu hình
curl -sSfL "https://raw.githubusercontent.com/Phamtuananhh2k5/xray/main/code_xrayr_aws.txt" >> "$config_file"

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
