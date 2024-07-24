#!/bin/bash
sudo apt update
sudo apt-get install net-tools -y
sudo apt-get install grep -y
sudo apt-get install gawk -y
sudo apt-get install sed -y
sudo apt-get install coreutils -y

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

sudo mkdir -p /etc/anti-ddos && \
sudo bash -c 'cat << EOF > /etc/anti-ddos/script.sh
#!/bin/bash
sudo iptables -w -F
sudo iptables -w -X
sudo iptables -w -t nat -F
sudo iptables -w -t nat -X
sudo iptables -w -t mangle -F
sudo iptables -w -t mangle -X
sudo iptables -w -t raw -F
sudo iptables -w -t raw -X
sudo iptables -w -t security -F
sudo iptables -w -t security -X
EOF' && \
sudo chmod +x /etc/anti-ddos/script.sh && \
(crontab -l ; echo "0 * * * * /etc/anti-ddos/script.sh") | sudo crontab - && \
(crontab -l ; echo "* * * * * /etc/anti-ddos/etc/anti-ddos/check-ddos.sh") | sudo crontab - 

