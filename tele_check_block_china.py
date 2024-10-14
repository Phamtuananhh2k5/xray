import os
import subprocess
import time
import requests

# Các IP cần kiểm tra
CHECK_IPS = ['43.240.220.179', '111.180.200.1', '117.50.76.1', '202.189.9.1']
# File để lưu thời gian gửi thông báo lần cuối
LAST_NOTIFY_FILE = "/root/last_notify_time.txt"

# Thông tin của bot Telegram
TELEGRAM_TOKEN = "REMOVED"  # Token bot của bạn
CHAT_ID = 5179418894  # CHAT_ID của bạn

# Hàm lấy IP của VPS từ ipinfo.io
def get_vps_ip():
    try:
        result = subprocess.run(['curl', '-s', 'ipinfo.io/ip'], stdout=subprocess.PIPE)
        vps_ip = result.stdout.decode('utf-8').strip()
        return vps_ip
    except Exception as e:
        print(f"Lỗi khi lấy IP của VPS: {e}")
        return None

# Hàm ping IP
def ping_ip(ip):
    response = os.system(f"ping -c 4 {ip} > /dev/null 2>&1")  # Thực hiện 4 lần ping và ẩn thông báo
    return response == 0  # Trả về True nếu ping thành công, False nếu không thành công

# Hàm gửi thông báo qua Telegram
def send_telegram_message(text):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    payload = {
        'chat_id': CHAT_ID,
        'text': text
    }
    
    try:
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            print("Thông báo đã được gửi đến Telegram.")
        else:
            print(f"Lỗi khi gửi thông báo: {response.text}")
    except Exception as e:
        print(f"Lỗi khi gửi thông báo: {e}")

# Hàm lấy thời gian gửi thông báo lần cuối từ file
def get_last_notify_time():
    try:
        with open(LAST_NOTIFY_FILE, 'r') as file:
            last_time = float(file.read())
            return last_time
    except FileNotFoundError:
        return 0  # Nếu file không tồn tại, coi như chưa từng gửi thông báo

# Hàm lưu thời gian gửi thông báo hiện tại
def save_last_notify_time():
    with open(LAST_NOTIFY_FILE, 'w') as file:
        file.write(str(time.time()))

# Lấy IP của VPS
VPS_IP = get_vps_ip()

if VPS_IP:
    # Kiểm tra các IP và chỉ gửi thông báo nếu tất cả đều không ping được
    all_failed = True
    for ip in CHECK_IPS:
        if ping_ip(ip):
            all_failed = False  # Nếu ping được ít nhất một IP, không cần gửi thông báo
            print(f"Ping thành công đến IP: {ip}")
            break
        else:
            print(f"Không thể ping đến IP: {ip}")

    if all_failed:
        # Nếu không ping được bất kỳ IP nào, kiểm tra thời gian gửi thông báo lần cuối
        last_notify_time = get_last_notify_time()
        current_time = time.time()
        if current_time - last_notify_time > 1800:  # 30 phút = 1800 giây
            text = f"IP máy chủ {VPS_IP} đã bị chặn tại Trung Quốc. Vui lòng đổi IP."
            send_telegram_message(text)  # Gửi thông báo tới Telegram
            save_last_notify_time()  # Lưu thời gian gửi thông báo hiện tại
        else:
            print("Đã gửi thông báo cảnh báo trong vòng 30 phút trước, không gửi lại.")
else:
    print("Không thể lấy IP của VPS.")
