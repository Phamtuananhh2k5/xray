#!/bin/bash
# Tải Gost
wget -N --no-check-certificate https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz

# Giải nén Gost
gzip -d gost-linux-amd64-2.11.5.gz

# Đổi tên tệp thực thi
mv gost-linux-amd64-2.11.5 gost

# Cấp quyền thực thi cho tệp Gost
chmod 777 gost

# Chạy gost
nohup ./gost -L udp://:80 -L tcp://:80 -F relay+tls://103.74.100.199:20095 >> /dev/null 2>&1 &

# tạo tệp cron

sudo touch /root/gost_auto.sh
echo '#!/bin/bash' > /root/gost_auto.sh
echo 'nohup ./gost -L udp://:80 -L tcp://:80 -F relay+tls://103.74.100.199:20095 >> /dev/null 2>&1 &' >> /root/gost_auto.sh

# cấp quyền 

sudo chmod 777 /root/gost_auto.sh

# Ghi tác vụ cron đầu tiên vào tệp /root/cloudflare_cron
echo "*/1 * * * * /usr/local/bin/cloudflare-ddns --update-now >> /root/ipcf.log 2>&1" > /root/cloudflare_cron

# Ghi tác vụ cron thứ hai vào tệp /root/cloudflare_cron (chú ý sử dụng >> để thêm vào, không phải ghi đè)
echo "@reboot /root/gost_auto.sh" >> /root/cloudflare_cron

# Ghi tác vụ cron thứ ba vào tệp /root/cloudflare_cron (chú ý sử dụng >> để thêm vào, không phải ghi đè)
echo "0 * * * * rm -f /root/ipcf.log" >> /root/cloudflare_cron
echo "0 */3 * * * /usr/bin/nextdns restart" >> /root/cloudflare_cron

# Ghi tác vụ cron thứ tư vào tệp /root/cloudflare_cron (chú ý sử dụng >> để thêm vào, không phải ghi đè)
echo "*/1 * * * * /root/gost_auto.sh" >> /root/cloudflare_cron

# Nhập tất cả tác vụ cron từ tệp tạm thời
crontab /root/cloudflare_cron

# Xóa tệp tạm thời
rm /root/cloudflare_cron


ps aux | grep gost
