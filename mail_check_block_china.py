import os
import smtplib
import subprocess
import time
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging

# Thiết lập logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Các IP cần kiểm tra
CHECK_IPS = ['43.240.220.179', '111.180.200.1', '117.50.76.1', '202.189.9.1']
# File để lưu thời gian gửi email lần cuối
LAST_EMAIL_FILE = "/root/last_email_time.txt"
# File lưu số AWS
AWS_NUMBER_FILE = "/root/aws_number.txt"
EMAIL_SENDER = "mail.check.block.dualeo@gmail.com"
EMAIL_PASSWORD = "uzqamacikbqqufhl"  # Lưu mật khẩu trực tiếp trong mã (không khuyến khích)

# Hàm lấy IP của VPS từ ipinfo.io
def get_vps_ip():
    try:
        result = subprocess.run(['curl', '-s', 'ipinfo.io/ip'], stdout=subprocess.PIPE, check=True)
        vps_ip = result.stdout.decode('utf-8').strip()
        return vps_ip
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi khi lấy IP của VPS: {e}")
        return None

# Hàm ping IP
def ping_ip(ip):
    response = os.system(f"ping -c 4 {ip} > /dev/null 2>&1")  # Ẩn đầu ra
    return response == 0

# Hàm gửi email
def send_email(subject, body, to_emails):
    # Đọc số AWS từ file
    aws_number = ""
    try:
        with open(AWS_NUMBER_FILE, 'r') as file:
            aws_number = file.read().strip()
    except FileNotFoundError:
        logging.warning("Không tìm thấy file lưu số AWS.")

    # Thêm số AWS vào nội dung email
    if aws_number:
        body += f"\n\nThông tin AWS: {aws_number}"

    msg = MIMEMultipart()
    msg['From'] = EMAIL_SENDER
    msg['To'] = ', '.join(to_emails)
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()
            server.login(EMAIL_SENDER, EMAIL_PASSWORD)
            server.sendmail(EMAIL_SENDER, to_emails, msg.as_string())
            logging.info(f"Email đã được gửi tới {', '.join(to_emails)}")
            print("Email đã được gửi thành công.")  # Thông báo cho người dùng
    except Exception as e:
        logging.error(f"Lỗi khi gửi email: {e}")
        print("Gửi email không thành công. Vui lòng kiểm tra log để biết thêm chi tiết.")  # Thông báo lỗi cho người dùng

# Hàm lấy thời gian gửi email lần cuối từ file
def get_last_email_time():
    try:
        with open(LAST_EMAIL_FILE, 'r') as file:
            return float(file.read())
    except FileNotFoundError:
        return 0

# Hàm lưu thời gian gửi email hiện tại
def save_last_email_time():
    with open(LAST_EMAIL_FILE, 'w') as file:
        file.write(str(time.time()))

# Lấy IP của VPS
VPS_IP = get_vps_ip()

if VPS_IP:
    all_failed = True
    for ip in CHECK_IPS:
        if ping_ip(ip):
            all_failed = False
            logging.info(f"Ping thành công đến IP: {ip}")
            break
        else:
            logging.warning(f"Không thể ping đến IP: {ip}")

    if all_failed:
        last_email_time = get_last_email_time()
        current_time = time.time()
        if current_time - last_email_time > 1800:  # 30 phút
            subject = f"IP máy chủ {VPS_IP} đã bị chặn tại Trung Quốc"
            body = f"IP máy chủ {VPS_IP} đã bị chặn tại Trung Quốc. Vui lòng đổi IP."
            send_email(subject, body, ["thanhdinhdnbg@gmail.com", "thanhdinhbgdn@gmail.com"])
            save_last_email_time()
        else:
            logging.info("Đã gửi email cảnh báo trong vòng 30 phút trước, không gửi lại.")
else:
    logging.error("Không thể lấy IP của VPS.")
