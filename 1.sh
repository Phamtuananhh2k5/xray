# Tìm và xóa file 1.sh, a.sh, b.sh nếu tồn tại


files_to_delete=("1.sh" "a.sh" "b.sh")

for file in "${files_to_delete[@]}"; do
    if [ -e "$file" ]; then
        rm "$file" >/dev/null 2>&1  # Xóa file mà không hiển thị output
    fi
done


do_red='\033[0;31m'
do_green='\033[0;32m'
do_yellow='\033[0;33m'
do_plain='\033[0m'

thu_muc_hien_tai=$(pwd)

# Kiểm tra quyền root
[[ $EUID -ne 0 ]] && echo -e "${do_red}Lỗi:${do_plain} Bạn cần chạy script này với quyền root!\n" && exit 1

# Kiểm tra hệ điều hành
if [[ -f /etc/redhat-release ]]; then
    he_dieu_hanh="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    he_dieu_hanh="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    he_dieu_hanh="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    he_dieu_hanh="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    he_dieu_hanh="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    he_dieu_hanh="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    he_dieu_hanh="centos"
else
    echo -e "${do_red}Không phát hiện phiên bản hệ điều hành, vui lòng liên hệ tác giả script!${do_plain}\n" && exit 1
fi

kien_truc=$(arch)

if [[ $kien_truc == "x86_64" || $kien_truc == "x64" || $kien_truc == "amd64" ]]; then
    kien_truc="64"
elif [[ $kien_truc == "aarch64" || $kien_truc == "arm64" ]]; then
    kien_truc="arm64-v8a"
elif [[ $kien_truc == "s390x" ]]; then
    kien_truc="s390x"
else
    kien_truc="64"
    echo -e "${do_red}Không thể xác định kiến trúc, sử dụng mặc định: ${kien_truc}${do_plain}"
fi

echo "Kiến trúc: ${kien_truc}"

if [ "$(getconf WORD_BIT)" != '32' ] && [ "$(getconf LONG_BIT)" != '64' ] ; then
    echo "Phần mềm này không hỗ trợ hệ điều hành 32 bit (x86), vui lòng sử dụng hệ điều hành 64 bit (x86_64). Nếu có vấn đề xác nhận, vui lòng liên hệ tác giả."
    exit 2
fi

phien_ban_os=""

# Phiên bản hệ điều hành
if [[ -f /etc/os-release ]]; then
    phien_ban_os=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$phien_ban_os" && -f /etc/lsb-release ]]; then
    phien_ban_os=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${he_dieu_hanh}" == x"centos" ]]; then
    if [[ ${phien_ban_os} -le 6 ]]; then
        echo -e "${do_red}Vui lòng sử dụng CentOS 7 hoặc cao hơn!${do_plain}\n" && exit 1
    fi
elif [[ x"${he_dieu_hanh}" == x"ubuntu" ]]; then
    if [[ ${phien_ban_os} -lt 16 ]]; then
        echo -e "${do_red}Vui lòng sử dụng Ubuntu 16 hoặc cao hơn!${do_plain}\n" && exit 1
    fi
elif [[ x"${he_dieu_hanh}" == x"debian" ]]; then
    if [[ ${phien_ban_os} -lt 8 ]]; then
        echo -e "${do_red}Vui lòng sử dụng Debian 8 hoặc cao hơn!${do_plain}\n" && exit 1
    fi
fi

cai_dat_co_ban() {
    if [[ x"${he_dieu_hanh}" == x"centos" ]]; then
        yum install epel-release -y
        yum install wget curl unzip tar crontabs socat -y
    else
        apt update -y
        apt install wget curl unzip tar cron socat -y
    fi
}


clear
read -p "
Chọn tên người dùng 
1: dualeo 
2: thanh 
Enter để sử dụng mặc định dualeo
Vui lòng nhập số : " choice

case $choice in
    1|"dualeo")
        bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/a.sh)
        ;;
    2|"thanh")
        bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/b.sh)
        ;;
    *)
        echo "Chọn không hợp lệ. Mặc định sẽ chọn dualeo."
        bash <(curl -Ls  https://raw.githubusercontent.com/Panhuqusyxh/xray/main/a.sh)
        ;;
esac
