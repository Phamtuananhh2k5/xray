import requests
from ping3 import ping

def check_ping(ip):
    """Kiểm tra xem IP có ping được không."""
    response = ping(ip, timeout=2)  # Thời gian chờ 2 giây
    return response is not None

def main():
    CF_API_TOKEN = 'YMsaJHMe_MhZHX85pQXsJxR9aAukP5hPkutDoElp'  # Thay bằng API Token của bạn
    CF_ZONE_ID = '58ed1415af208e929ce742305f3c0e12'  # Thay bằng Zone ID của bạn
    url = f'https://api.cloudflare.com/client/v4/zones/{CF_ZONE_ID}/dns_records'

    headers = {
        'Authorization': f'Bearer {CF_API_TOKEN}',
        'Content-Type': 'application/json',
    }

    # Lấy tất cả bản ghi DNS
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        dns_records = response.json()
        for record in dns_records['result']:
            ip = record['content']
            record_id = record['id']
            print(f"Đang kiểm tra IP: {ip}")

            if check_ping(ip):
                print(f"IP {ip} ping được, giữ nguyên.")
            else:
                print(f"IP {ip} không ping được, xóa bản ghi.")
                delete_url = f"{url}/{record_id}"
                delete_response = requests.delete(delete_url, headers=headers)

                if delete_response.status_code == 200:
                    print(f"Đã xóa IP {ip}.")
                else:
                    print(f"Lỗi khi xóa IP {ip}: {delete_response.status_code} - {delete_response.text}")
    else:
        print(f"Error: {response.status_code} - {response.text}")

if __name__ == "__main__":
    main()
