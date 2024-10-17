#!/bin/bash
#pkill gost
# Khởi động lại gost với các tham số cần thiết
nohup gost \
    -L "tcp://:16000/1.phamanh.id.vn:16000,2.phamanh.id.vn:16000,3.phamanh.id.vn:16000,4.phamanh.id.vn:16000,36.50.135.0:16000?strategy=round&maxFails=1&failTimeout=300s" \
    -L "udp://:16000/1.phamanh.id.vn:16000,2.phamanh.id.vn:16000,3.phamanh.id.vn:16000,4.phamanh.id.vn:16000,36.50.135.0:16000?strategy=round&maxFails=1&failTimeout=300s" \
    -L "tcp://:10095/1.phamanh.id.vn:10095,2.phamanh.id.vn:10095,3.phamanh.id.vn:10095,4.phamanh.id.vn:10095,36.50.135.0:10095?strategy=round&maxFails=1&failTimeout=300s" \
    -L "udp://:10095/1.phamanh.id.vn:10095,2.phamanh.id.vn:10095,3.phamanh.id.vn:10095,4.phamanh.id.vn:10095,36.50.135.0:10095?strategy=round&maxFails=1&failTimeout=300s" \
    -L "tcp://:10099/1.phamanh.id.vn:10099,2.phamanh.id.vn:10099,3.phamanh.id.vn:10099,4.phamanh.id.vn:10099,36.50.135.0:10099?strategy=round&maxFails=1&failTimeout=300s" \
    -L "udp://:10099/1.phamanh.id.vn:10099,2.phamanh.id.vn:10099,3.phamanh.id.vn:10099,4.phamanh.id.vn:10099,36.50.135.0:10099?strategy=round&maxFails=1&failTimeout=300s" \
    > /dev/null 2>&1 &


