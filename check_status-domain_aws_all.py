import requests
import json
import subprocess
from ping3 import ping

# Đường dẫn tới file cấu hình
CONFIG_FILE = '/root/information.txt'

# Hàm đọc file cấu hình
def read_config(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    configs = []
    current_config = {}
    
    for line in lines:
        line = line.strip()
        if not line:  # Bỏ qua dòng trống
            continue
        
        if line.startswith('CF_API_TOKEN'):
            if current_config:  # Lưu cấu hình hiện tại nếu đã đầy đủ
                configs.append(current_config)
                current_config = {}
            current_config['CF_API_TOKEN'] = line.split('=')[1].strip().strip("'")
        
        elif line.startswith('CF_ZONE_ID'):
            current_config['CF_ZONE_ID'] = line.split('=')[1].strip().strip("'")
        
        elif line.startswith('CF_RECORD_NAME'):
            current_config['CF_RECORD_NAME'] = line.split('=')[1].strip().strip("'")
    
    if current_config:  # Lưu cấu hình cuối cùng
        configs.append(current_config)
    
    return configs

# Hàm lấy IP hiện tại từ lệnh curl ipinfo.io
def get_current_ip():
    result = subprocess.run(['curl', 'ipinfo.io/ip'], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

# Hàm kiểm tra xem IP có ping được không
def check_ping(ip):
    response = ping(ip, timeout=2)  # Thời gian chờ 2 giây
    return response is not None

# Hàm lấy các bản ghi A hiện có
def get_a_records(api_token, zone_id, record_name):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    params = {
        "type": "A",
        "name": record_name
    }
    
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        return response.json().get("result", [])
    else:
        print(f"Error fetching DNS records for {record_name}: {response.status_code}")
        print(response.text)
        return []

# Hàm thêm một bản ghi DNS mới
def add_a_record(api_token, zone_id, record_name, ip):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    data = {
        "type": "A",
        "name": record_name,
        "content": ip,
        "ttl": 60,  # Thời gian TTL (có thể chỉnh)
        "proxied": False  # Nếu muốn bật proxy Cloudflare, để True
    }
    
    response = requests.post(url, headers=headers, data=json.dumps(data))
    if response.status_code == 200:
        print(f"Added new IP: {ip} for {record_name}")
    else:
        print(f"Error adding new IP: {response.status_code}")
        print(response.text)

# Hàm xóa bản ghi DNS
def delete_record(api_token, zone_id, record_id):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    
    response = requests.delete(url, headers=headers)
    if response.status_code == 200:
        print(f"Deleted record with ID: {record_id}")
    else:
        print(f"Error deleting record: {response.status_code}")
        print(response.text)

# Hàm duy trì các bản ghi DNS
def maintain_records(configs):
    current_ip = get_current_ip()
    print(f"Current IP: {current_ip}")
    
    for config in configs:
        api_token = config['CF_API_TOKEN']
        zone_id = config['CF_ZONE_ID']
        record_name = config['CF_RECORD_NAME']
        
        print(f"Processing {record_name}")
        
        a_records = get_a_records(api_token, zone_id, record_name)
        active_records = [record for record in a_records if check_ping(record['content'])]
        
        # Xóa các bản ghi không hoạt động
        for record in a_records:
            if record not in active_records:
                delete_record(api_token, zone_id, record['id'])
        
        # Thêm IP hiện tại nếu chưa tồn tại
        if not any(record['content'] == current_ip for record in active_records):
            add_a_record(api_token, zone_id, record_name, current_ip)

# Chạy chính
def main():
    configs = read_config(CONFIG_FILE)
    maintain_records(configs)

if __name__ == "__main__":
    main()
