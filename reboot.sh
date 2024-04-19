


echo '#!/bin/bash

check_cpu_load() {
    # Lấy phần trăm tải CPU
    cpu_load=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '"'"'{print 100 - $1}'"'"')
    echo "Tải CPU hiện tại: $cpu_load%"

    # Kiểm tra nếu tải CPU lớn hơn 90%
    if (( $(echo "$cpu_load > 90" | bc -l) )); then
        echo "Tải CPU vượt quá ngưỡng 90%. Khởi động lại hệ thống..."
        sudo reboot
    fi
}

check_cpu_load' > reboot1.sh

chmod 777 reboot1.sh

echo "*/2 * * * * /root/reboot1.sh >/dev/null 2>&1" | sudo crontab -

