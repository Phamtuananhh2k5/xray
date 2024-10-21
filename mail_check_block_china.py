import os
import smtplib
import subprocess
import time
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Các IP cần kiểm tra
CHECK_IPS = ['43.240.220.179', '111.180.200.1', '117.50.76.1', '202.189.9.1']
# File để lưu thời gian gửi email lần cuối
LAST_EMAIL_FILE = "/root/last_email_time.txt"

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
    response = os.system(f"ping -c 4 {ip}")  # Thực hiện 4 lần ping
    return response == 0  # Trả về True nếu ping thành công, False nếu không thành công

# Hàm gửi email
def send_email(subject, body, to_emails):
    from_email = "phamanh8084@gmail.com"
    password = "lyxdlbjcvyavpjet"

    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = ', '.join(to_emails)  # Thay đổi để gửi tới nhiều email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(from_email, password)
        text = msg.as_string()
        server.sendmail(from_email, to_emails, text)  # Gửi tới nhiều email
        server.quit()
        print(f"Email đã được gửi tới {', '.join(to_emails)}")
    except Exception as e:
        print(f"Lỗi khi gửi email: {e}")

# Hàm lấy thời gian gửi email lần cuối từ file
def get_last_email_time():
    try:
        with open(LAST_EMAIL_FILE, 'r') as file:
            last_time = float(file.read())
            return last_time
    except FileNotFoundError:
        return 0  # Nếu file không tồn tại, coi như chưa từng gửi email

# Hàm lưu thời gian gửi email hiện tại
def save_last_email_time():
    with open(LAST_EMAIL_FILE, 'w') as file:
        file.write(str(time.time()))

# Lấy IP của VPS
VPS_IP = get_vps_ip()

if VPS_IP:
    # Kiểm tra các IP và chỉ gửi email nếu tất cả đều không ping được
    all_failed = True
    for ip in CHECK_IPS:
        if ping_ip(ip):
            all_failed = False  # Nếu ping được ít nhất một IP, không cần gửi email
            print(f"Ping thành công đến IP: {ip}")
            break
        else:
            print(f"Không thể ping đến IP: {ip}")

    if all_failed:
        # Nếu không ping được bất kỳ IP nào, kiểm tra thời gian gửi email lần cuối
        last_email_time = get_last_email_time()
        current_time = time.time()
        if current_time - last_email_time > 1800:  # 30 phút = 1800 giây
            subject = f"IP máy chủ {VPS_IP} đã bị chặn tại Trung Quốc"
            body = f"IP máy chủ {VPS_IP} đã bị chặn tại Trung Quốc. Vui lòng đổi IP."
            send_email(subject, body, ["thannhdinhdnbg@gmail.com", "thanhdinhbgdn@gmail.com"])  # Gửi tới hai địa chỉ email
            save_last_email_time()  # Lưu thời gian gửi email hiện tại
        else:
            print("Đã gửi email cảnh báo trong vòng 30 phút trước, không gửi lại.")
else:
    print("Không thể lấy IP của VPS.")
