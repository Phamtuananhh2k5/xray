#!/bin/bash

# Cập nhật hệ thống và cài đặt WireGuard
sudo apt update && sudo apt install wireguard -y && sudo apt install resolvconf -y


# Kiểm tra xem WireGuard đã được cài đặt thành công chưa
if ! command -v wg > /dev/null 2>&1; then
    echo "Cài đặt WireGuard thất bại! Vui lòng kiểm tra lại."
    exit 1
fi

# Hiển thị danh sách các server và hỏi người dùng chọn server nào
echo "Chọn server WireGuard bạn muốn kết nối:"
echo "1) Server 1 (103.186.67.181:51820)"
echo "2) Server 2 (103.187.5.188:51820)"
echo "3) Server 3 (202.55.135.112:51820)"
echo "4) Server 4 (103.167.92.110:51820)"
read -p "Nhập số server (1-4): " server_choice

# Dựa vào lựa chọn của người dùng, cấu hình thông tin tương ứng
case $server_choice in
    1)
        PRIVATE_KEY="aK3VEkz5HWhmYEQ3HDHt5HjKkbjv4b6ngVEwK7bwRm4="
        PUBLIC_KEY="V3f1/2dP3LIfmkeIq6edpsCLTNWo3VpvCvAfuwTlGH0="
        PRESHARED_KEY="zLHlx9V5pLZRv79n9OhPdqKUmWAnltHj7Xvzis2T7RU="
        ENDPOINT="103.186.67.181:51820"
        ;;
    2)
        PRIVATE_KEY="KFePe7e5h1KHf9jZ+Wc/chSBF/a+TSYYrD1T8gxBs0I="
        PUBLIC_KEY="jEImGmyO9loib1i6X0ZSdUgzRU3VEjFJc9SS+tN+OhU="
        PRESHARED_KEY="uB0FoZ6dCAdYLnMtXLz8q7gSemnnSDxvuIsLdg4e9SU="
        ENDPOINT="103.187.5.188:51820"
        ;;
    3)
        PRIVATE_KEY="aPcr0JUrXOGWlA3pfOgLguKG+uOGl2LpcbkoTH/1CnE="
        PUBLIC_KEY="rDgZmb0iWwkcjVaIdYpiE8yrR2Eny4vWmzm3MtuMhCo="
        PRESHARED_KEY="Ln9j4xE8vsmul6uUjCrmScx+rZ45yAUNJJRfBnDArEY="
        ENDPOINT="202.55.135.112:51820"
        ;;
    4)
        PRIVATE_KEY="eNef8gNHZAbU+7kBh0jP1u6MpvOwH84mHu67h1QGV0o="
        PUBLIC_KEY="qot7utaIfzjxV06lIQ6RW3JDNhZ8F3PU9tGAhKzveFM="
        PRESHARED_KEY="obqRm/kYgdUMezZfiUJsH7qEcot2UrehyOtEVG/0kio="
        ENDPOINT="103.167.92.110:51820"
        ;;
    *)
        echo "Lựa chọn không hợp lệ!"
        exit 1
        ;;
esac

# Kiểm tra và tạo thư mục /etc/wireguard nếu chưa tồn tại
if [ ! -d "/etc/wireguard" ]; then
    sudo mkdir -p /etc/wireguard
fi

# Tạo hoặc cập nhật file wgcf.conf
WGCF_CONF="/etc/wireguard/wgcf.conf"
sudo bash -c "cat > $WGCF_CONF <<EOL
[Interface]
Address = 10.7.0.2/24
DNS = 1.1.1.1, 1.0.0.1
PrivateKey = $PRIVATE_KEY

[Peer]
PublicKey = $PUBLIC_KEY
PresharedKey = $PRESHARED_KEY
AllowedIPs = 23.209.44.0/22,18.198.0.0/15,3.164.224.0/21,2600:9000:2365::/48,13.224.160.0/21,2600:9000:2135::/48,18.138.0.0/15,23.215.4.0/22,159.183.192.0/19,50.31.32.0/20,149.72.0.0/16,167.89.0.0/17,159.183.64.0/18,168.245.0.0/17,131.186.8.0/21,199.60.103.0/24,2606:2c40::/48,71.18.0.0/16,10.0.0.0/8,199.232.0.0/17,146.75.40.0/21,209.127.230.0/23,130.44.212.0/22,147.160.184.0/24,52.86.0.0/15,35.168.0.0/13,18.208.0.0/13,23.192.150.0/23,23.204.147.0/24,23.52.40.0/22,23.210.250.0/24,96.16.48.0/21,23.72.90.0/24,72.246.103.0/24,23.200.72.0/22,23.202.33.0/24,23.47.190.0/24,23.32.0.0/11,104.110.191.0/24,23.48.32.0/23,23.192.0.0/11,104.109.136.0/21,103.136.220.0/23,43.132.80.0/23,199.190.44.0/22,182.0.0.0/15,34.105.128.0/17,34.107.0.0/16,34.117.0.0/16,34.101.0.0/16,138.113.16.0/22,199.103.25.0/24,177.246.72.0/21,138.113.150.0/24,103.120.247.0/24,138.113.24.0/21,138.113.117.0/24,185.235.10.0/24,139.177.240.0/21,178.249.208.0/21,161.49.0.0/19,111.119.190.0/23,179.40.128.0/17,199.103.24.0/24,147.160.187.0/24,147.160.176.0/21,139.177.238.0/23,139.177.224.0/22,139.177.236.0/24,139.177.232.0/23,92.223.80.0/21,23.54.155.0/24,115.67.100.0/23,115.67.108.0/24,143.47.224.0/19,150.230.20.0/22,71.18.0.0/16,127.0.0.0/8,104.98.117.0/24,23.67.33.0/24,161.117.0.0/17,34.143.128.0/17,34.102.0.0/15,34.120.0.0/14,156.146.32.0/21,143.244.42.0/23,212.102.32.0/19,195.181.160.0/20,185.59.220.0/22,23.219.64.0/20,116.206.136.0/22,179.191.174.0/23,185.235.10.0/24,179.191.177.0/24,18.154.0.0/15,18.160.0.0/15,127.0.0.0/8,169.254.0.0/16,10.0.0.0/8,71.18.0.0/16,103.136.220.0/23,13.33.30.0/24,2600:9000:223b::/48,3.165.80.0/21,2600:9000:229f::/48,54.230.0.0/15,2600:9000:271a::/48,108.156.0.0/14,65.8.11.0/24,13.33.88.0/22,2600:9000:2000::/45,108.156.132.0/22,3.163.124.0/22,3.124.0.0/14,2600:9000:2755::/48,3.165.96.0/21,111.119.190.0/23,111.119.176.0/21,111.119.184.0/24,79.127.128.0/17,14.238.84.0/24,161.117.0.0/17,199.232.0.0/17,151.101.200.0/22,130.44.212.0/22,147.160.184.0/24,147.160.190.0/24,139.177.224.0/22,92.223.94.0/23,116.51.16.0/20,23.44.175.0/24,2600:1901::/32,34.32.0.0/11,34.148.0.0/14,35.245.128.0/20,35.244.0.0/16,172.67.0.0/16,104.16.0.0/12,2606:4700::/32,130.35.48.0/20,23.45.206.0/23,23.215.4.0/22,2.16.224.0/19,34.120.0.0/14,34.117.0.0/16,34.143.128.0/17,34.102.0.0/15,35.213.128.0/18,34.64.0.0/10,35.186.192.0/18,35.200.0.0/15,34.145.0.0/16,23.200.72.0/22,2600:1400::/24,23.211.108.0/22,23.200.218.0/24,23.32.28.0/23,125.56.218.0/23,23.210.250.0/24,184.87.193.0/24,2.16.154.0/24,23.54.155.0/24,2.19.198.0/24,23.44.4.0/22,88.221.132.0/22,184.50.85.0/24,23.209.44.0/22
Endpoint = $ENDPOINT
PersistentKeepalive = 25
EOL"

echo "File cấu hình WireGuard đã được cập nhật tại $WGCF_CONF."

# Sau khi cấu hình hoàn tất, hỏi người dùng có muốn bật/tắt kết nối hay không
echo "Bạn muốn làm gì tiếp theo?"
echo "1) Kết nối WireGuard"
echo "2) Tắt kết nối WireGuard"
echo "3) Khởi động lại kết nối WireGuard"
read -p "Nhập lựa chọn của bạn (1-3): " action_choice

# Dựa vào lựa chọn của người dùng, bật/tắt WireGuard
if [ "$action_choice" = "1" ]; then
    # Bật kết nối WireGuard
    sudo wg-quick up /etc/wireguard/wgcf.conf
    echo "Kết nối WireGuard đã được thiết lập."
elif [ "$action_choice" = "2" ]; then
    # Tắt kết nối WireGuard
    sudo wg-quick down /etc/wireguard/wgcf.conf
    echo "Kết nối WireGuard đã tắt."
elif [ "$action_choice" = "3" ]; then
    # Bật lại kết nối WireGuard
    sudo wg-quick down /etc/wireguard/wgcf.conf && sudo wg-quick up /etc/wireguard/wgcf.conf
    echo "Kết nối WireGuard đã bật lại."
else
    echo "Lựa chọn không hợp lệ!"
    exit 1
fi
