import requests
import json
import subprocess
from ping3 import ping

# Cấu hình API Cloudflare
CF_API_TOKEN = '31S6HnuIYVDzFj0N_dYM3q93Xt0F16rP0Bjme2m7'
CF_ZONE_ID = '6861bf621cba2cb4ea0a2c01674c4cb6'
CF_RECORD_NAME = 'a.hoalam.site'

# Hàm lấy IP hiện tại từ lệnh curl ifconfig.me
def get_current_ip():
    result = subprocess.run(['curl', 'ifconfig.me'], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

# Hàm kiểm tra xem IP có ping được không
def check_ping(ip):
    response = ping(ip, timeout=2)  # Thời gian chờ 2 giây
    print(f"Kiểm tra ping cho IP {ip}: {'ping được' if response else 'không ping được'}")
    return response is not None

# Hàm lấy các bản ghi A hiện có
def get_a_records():
    url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records"
    headers = {
        "Authorization": f"Bearer {CF_API_TOKEN}",
        "Content-Type": "application/json"
    }
    params = {
        "type": "A",
        "name": CF_RECORD_NAME
    }
    
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        return response.json().get("result", [])
    else:
        print(f"Error fetching DNS records: {response.status_code}")
        print(response.text)
        return []

# Hàm thêm một bản ghi DNS mới
def add_a_record(ip):
    url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records"
    headers = {
        "Authorization": f"Bearer {CF_API_TOKEN}",
        "Content-Type": "application/json"
    }
    data = {
        "type": "A",
        "name": CF_RECORD_NAME,
        "content": ip,
        "ttl": 60,  # Thời gian TTL (có thể chỉnh)
        "proxied": False  # Nếu muốn bật proxy Cloudflare, để True
    }
    
    response = requests.post(url, headers=headers, data=json.dumps(data))
    if response.status_code == 200:
        print(f"Đã thêm IP mới: {ip}")
    else:
        print(f"Error adding new IP: {response.status_code}")
        print(response.text)

# Hàm xóa bản ghi DNS
def delete_record(record_id):
    url = f"https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records/{record_id}"
    headers = {
        "Authorization": f"Bearer {CF_API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    response = requests.delete(url, headers=headers)
    if response.status_code == 200:
        print(f"Đã xóa bản ghi với ID: {record_id}")
    else:
        print(f"Lỗi khi xóa bản ghi: {response.status_code} - {response.text}")

# Hàm duy trì nhiều bản ghi IP hoạt động
def maintain_multiple_active_records():
    a_records = get_a_records()  # Lấy danh sách các bản ghi A hiện có
    
    active_ips = []
    inactive_ips = []
    
    # Kiểm tra khả năng ping cho từng IP
    for record in a_records:
        ip = record['content']
        print(f"Đang kiểm tra IP: {ip}")

        if check_ping(ip):
            print(f"IP {ip} ping được.")
            active_ips.append(record)  # Lưu bản ghi IP ping được
        else:
            print(f"IP {ip} không ping được.")
            inactive_ips.append(record)  # Lưu bản ghi IP không ping được
    
    # Xóa tất cả các IP không ping được
    for record in inactive_ips:
        print(f"Xóa IP không ping được: {record['content']}")
        delete_record(record['id'])
    
    # Nếu không có IP nào ping được, thêm IP mới
    if len(active_ips) == 0:
        current_ip = get_current_ip()
        print(f"Không có IP nào ping được. Thêm IP mới: {current_ip}")
        add_a_record(current_ip)
    else:
        # Thêm các IP mới mà chưa có trong danh sách
        existing_ips = {record['content'] for record in active_ips}
        current_ip = get_current_ip()

        if current_ip not in existing_ips:
            print(f"Thêm IP mới: {current_ip}")
            add_a_record(current_ip)

# Chạy chính
def main():
    current_ip = get_current_ip()  # Lấy IP hiện tại từ curl ifconfig.me
    print(f"IP hiện tại: {current_ip}")
    
    # Duy trì nhiều bản ghi IP hoạt động
    maintain_multiple_active_records()

if __name__ == "__main__":
    main()
