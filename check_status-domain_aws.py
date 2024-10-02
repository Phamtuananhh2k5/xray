import requests
import json
import subprocess
from ping3 import ping

# Cấu hình API Cloudflare
CF_API_TOKEN = 'REMOVED'
CF_ZONE_ID = '49cd7086b2ba1f53c256851a9a0800b1'
CF_RECORD_NAME = 'hk1.chomchom.top'

# Hàm lấy IP hiện tại từ lệnh curl ifconfig.me
def get_current_ip():
    result = subprocess.run(['curl', 'ifconfig.me'], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

# Hàm kiểm tra xem IP có ping được không
def check_ping(ip):
    response = ping(ip, timeout=2)  # Thời gian chờ 2 giây
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

# Hàm xóa toàn bộ các IP không ping được
def delete_unpingable_records():
    a_records = get_a_records()  # Lấy danh sách các bản ghi A hiện có
    
    for record in a_records:
        ip = record['content']
        record_id = record['id']
        print(f"Đang kiểm tra IP: {ip}")

        if not check_ping(ip):  # Nếu IP không ping được
            print(f"IP {ip} không ping được, xóa bản ghi.")
            delete_record(record_id)  # Xóa bản ghi
        else:
            print(f"IP {ip} ping được, giữ nguyên.")

def main():
    current_ip = get_current_ip()  # Lấy IP hiện tại từ curl ifconfig.me
    print(f"IP hiện tại: {current_ip}")
    
    a_records = get_a_records()  # Lấy danh sách các bản ghi hiện có
    
    # Kiểm tra xem có IP nào ping được không
    any_ip_pingable = False
    for record in a_records:
        ip = record['content']
        print(f"Đang kiểm tra IP: {ip}")

        if check_ping(ip):
            print(f"IP {ip} ping được.")
            any_ip_pingable = True
        else:
            print(f"IP {ip} không ping được.")
    
    # Chỉ thêm IP mới nếu không có IP nào ping được
    if not any_ip_pingable:
        print(f"Không có IP nào ping được. Thêm IP mới: {current_ip}")
        add_a_record(current_ip)
    else:
        print(f"Đã có IP ping được. Không thêm IP mới.")

    # Xóa các IP không ping được
    delete_unpingable_records()

if __name__ == "__main__":
    main()
