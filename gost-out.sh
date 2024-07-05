# Tải Gost
wget -N --no-check-certificate https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz

# Giải nén Gost
gzip -d gost-linux-amd64-2.11.5.gz

# Đổi tên tệp thực thi
mv gost-linux-amd64-2.11.5 gost

# Cấp quyền thực thi cho tệp Gost
chmod 777 gost

# Chạy gost

# ./gost -L udp://:10090 -L tcp://:10090 -F http://127.0.0.1:1080 -F relay+tls://38.54.31.254:20090 >> /dev/null 2>&1 &

nohup ./gost -L udp://:10095 -L tcp://:10095 -F relay+tls://103.140.249.182:20095 >> /dev/null 2>&1 &
nohup ./gost -L relay+tls://:20095/127.0.0.1:10095 >> /dev/null 2>&1 &

nohup ./gost -L udp://:10010 -L tcp://:10010 -F relay+tls://103.140.249.182:20010 >> /dev/null 2>&1 &
nohup ./gost -L relay+tls://:20010/127.0.0.1:10010 >> /dev/null 2>&1 &

nohup ./gost -L udp://:10089 -L tcp://:10089 -F relay+tls://103.140.249.109:20089 >> /dev/null 2>&1 &
nohup ./gost -L relay+tls://:20089/127.0.0.1:10089 >> /dev/null 2>&1 &

nohup ./gost -L relay+tls://:20080/127.0.0.1:80 >> /dev/null 2>&1 &
# tạo tệp cron

sudo touch /root/gost_auto.sh
echo '#!/bin/bash' > /root/gost_auto.sh
echo 'nohup ./gost -L udp://:10095 -L tcp://:10095 -F relay+tls://103.140.249.182:20095 >> /dev/null 2>&1 &' >> /root/gost_auto.sh
echo 'nohup ./gost -L relay+tls://:20095/127.0.0.1:10095 >> /dev/null 2>&1 &' >> /root/gost_auto.sh

echo 'nohup ./gost -L udp://:10010 -L tcp://:10010 -F relay+tls://103.140.249.182:20010 >> /dev/null 2>&1 &' >> /root/gost_auto.sh
echo 'nohup ./gost -L relay+tls://:20010/127.0.0.1:10010 >> /dev/null 2>&1 &' >> /root/gost_auto.sh

echo 'nohup ./gost -L udp://:10089 -L tcp://:10089 -F relay+tls://103.140.249.109:20089 >> /dev/null 2>&1 &' >> /root/gost_auto.sh
echo 'nohup ./gost -L relay+tls://:20089/127.0.0.1:10089 >> /dev/null 2>&1 &' >> /root/gost_auto.sh

echo 'nohup ./gost -L relay+tls://:20080/127.0.0.1:80 >> /dev/null 2>&1 &' >> /root/gost_auto.sh


echo 'ps aux | grep gost' >> /root/gost_auto.sh


# cấp quyền 

sudo chmod 777 /root/gost_auto.sh

ps aux | grep gost
