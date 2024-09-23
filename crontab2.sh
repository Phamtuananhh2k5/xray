# Ghi tác vụ cron đầu tiên vào tệp /root/cloudflare_cron
echo "*/1 * * * * /root/check-update.sh" > /root/cloudflare_cron

# Ghi tác vụ cron thứ hai vào tệp /root/cloudflare_cron (chú ý sử dụng >> để thêm vào, không phải ghi đè)
echo "@reboot /root/gost_auto.sh" >> /root/cloudflare_cron

# Ghi tác vụ cron thứ ba vào tệp /root/cloudflare_cron (chú ý sử dụng >> để thêm vào, không phải ghi đè)
echo "0 * * * * rm -f /root/ipcf.log" >> /root/cloudflare_cron
echo "0 */3 * * * /usr/bin/nextdns restart" >> /root/cloudflare_cron

# Ghi tác vụ cron thứ tư vào tệp /root/cloudflare_cron (chú ý sử dụng >> để thêm vào, không phải ghi đè)
echo "*/1 * * * * /root/gost_auto.sh" >> /root/cloudflare_cron

echo "5 * * * * /root/nezha.sh restart_agent" >> /root/cloudflare_cron


# Nhập tất cả tác vụ cron từ tệp tạm thời
crontab /root/cloudflare_cron

# Xóa tệp tạm thời
rm /root/cloudflare_cron
