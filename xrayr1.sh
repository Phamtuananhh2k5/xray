#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# Kiểm tra quyền root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi:${plain} Cần chạy với quyền root!\n" && exit 1

# Kiểm tra hệ điều hành
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}Không phát hiện được phiên bản hệ điều hành, vui lòng liên hệ tác giả script!${plain}\n" && exit 1
fi

arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64-v8a"
elif [[ $arch == "s390x" ]]; then
    arch="s390x"
else
    arch="64"
    echo -e "${red}Kiểm tra kiến trúc thất bại, sử dụng kiến trúc mặc định: ${arch}${plain}"
fi

echo "Kiến trúc: ${arch}"

if [ "$(getconf WORD_BIT)" != '32' ] && [ "$(getconf LONG_BIT)" != '64' ] ; then
    echo "Phần mềm này không hỗ trợ hệ thống 32 bit (x86), vui lòng sử dụng hệ thống 64 bit (x86_64), nếu phát hiện lỗi, vui lòng liên hệ tác giả"
    exit 2
fi

os_version=""

# Phiên bản hệ điều hành
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Vui lòng sử dụng CentOS 7 hoặc phiên bản cao hơn của hệ điều hành!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Vui lòng sử dụng Ubuntu 16 hoặc phiên bản cao hơn của hệ điều hành!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Vui lòng sử dụng Debian 8 hoặc phiên bản cao hơn của hệ điều hành!${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install epel-release -y
        yum install wget curl unzip tar crontabs socat -y
    else
        apt update -y
        apt install wget curl unzip tar cron socat -y
    fi
}

# Trạng thái dịch vụ XrayR
# 0: đang chạy, 1: không chạy, 2: không cài đặt
check_status() {
    if [[ ! -f /etc/systemd/system/XrayR.service ]]; then
        return 2
    fi
    temp=$(systemctl status XrayR | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

install_acme() {
    curl https://get.acme.sh | sh
}

install_XrayR() {
    if [[ -e /usr/local/XrayR/ ]]; then
        rm /usr/local/XrayR/ -rf
    fi

    mkdir /usr/local/XrayR/ -p
    cd /usr/local/XrayR/

    if [ $# == 0 ]; then
        last_version="v0.8.8"
        echo -e "Bắt đầu cài đặt XrayR ${last_version}"
        wget -q -N --no-check-certificate -O /usr/local/XrayR/XrayR-linux.zip https://github.com/XrayR-project/XrayR/releases/download/${last_version}/XrayR-linux-${arch}.zip
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Tải về XrayR thất bại, vui lòng đảm bảo rằng máy chủ của bạn có thể tải về các tệp từ Github${plain}"
            exit 1
        fi
    else
        if [[ $1 == v* ]]; then
            last_version=$1
        else
            last_version="v"$1
        fi
        url="https://github.com/XrayR-project/XrayR/releases/download/${last_version}/XrayR-linux-${arch}.zip"
        echo -e "Bắt đầu cài đặt XrayR ${last_version}"
        wget -q -N --no-check-certificate -O /usr/local/XrayR/XrayR-linux.zip ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Tải về XrayR ${last_version} thất bại, vui lòng đảm bảo rằng phiên bản này tồn tại${plain}"
            exit 1
        fi
    fi

    unzip XrayR-linux.zip
    rm XrayR-linux.zip -f
    chmod +x XrayR
    mkdir /etc/XrayR/ -p
    rm /etc/systemd/system/XrayR.service -f
    file="https://github.com/XrayR-project/XrayR-release/raw/master/XrayR.service"
    wget -q -N --no-check-certificate -O /etc/systemd/system/XrayR.service ${file}
    systemctl daemon-reload
    systemctl stop XrayR
    systemctl enable XrayR
    echo -e "${green}XrayR ${last_version}${plain} đã cài đặt xong, đã cấu hình tự động khởi động"
    cp geoip.dat /etc/XrayR/
    cp geosite.dat /etc/XrayR/

    if [[ ! -f /etc/XrayR/config.yml ]]; then
        cp config.yml /etc/XrayR/
        echo -e ""
        echo -e "Cài đặt mới, vui lòng xem hướng dẫn tại: https://github.com/XrayR-project/XrayR, cấu hình nội dung cần thiết"
    else
        systemctl start XrayR
        sleep 2
        check_status
        echo -e ""
        if [[ $? == 0 ]]; then
            echo -e "${green}XrayR khởi động lại thành công${plain}"
        else
            echo -e "${red}XrayR có thể khởi động thất bại, vui lòng sau đó kiểm tra nhật ký sử dụng lệnh XrayR log, nếu không thể khởi động, có thể đã thay đổi định dạng cấu hình, vui lòng kiểm tra trang wiki: https://github.com/XrayR-project/XrayR/wiki${plain}"
        fi
    fi

    if [[ ! -f /etc/XrayR/dns.json ]]; then
        cp dns.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/route.json ]]; then
        cp route.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/custom_outbound.json ]]; then
        cp custom_outbound.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/custom_inbound.json ]]; then
        cp custom_inbound.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/rulelist ]]; then
        cp rulelist /etc/XrayR/
    fi
    curl -o /usr/bin/XrayR -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/XrayR.sh
    chmod +x /usr/bin/XrayR
    ln -s /usr/bin/XrayR /usr/bin/xrayr # tương thích chữ thường
    chmod +x /usr/bin/xrayr
    cd $cur_dir
    rm -f install.sh
    echo -e ""
    echo "Hướng dẫn sử dụng script quản lý XrayR (cũng có thể sử dụng xrayr, không phân biệt chữ hoa chữ thường): "
    echo "------------------------------------------"
    echo "XrayR                    - Hiển thị menu quản lý (có nhiều tính năng hơn)"
    echo "XrayR start              - Khởi động XrayR"
    echo "XrayR stop               - Dừng XrayR"
    echo "XrayR restart            - Khởi động lại XrayR"
    echo "XrayR status             - Xem trạng thái XrayR"
    echo "XrayR enable             - Cài đặt tự động khởi động XrayR"
    echo "XrayR disable            - Tắt tự động khởi động XrayR"
    echo "XrayR log                - Xem nhật ký XrayR"
    echo "XrayR update             - Cập nhật XrayR"
    echo "XrayR update x.x.x       - Cập nhật XrayR phiên bản cụ thể"
    echo "XrayR config             - Hiển thị nội dung tệp cấu hình"
    echo "XrayR install            - Cài đặt XrayR"
    echo "XrayR uninstall          - Gỡ cài đặt XrayR"
    echo "XrayR version            - Xem phiên bản XrayR"
    echo "------------------------------------------"
}

echo -e "${green}Bắt đầu cài đặt${plain}"
install_base
# install_acme
install_XrayR $1



# Tìm và xóa file 1.sh, a.sh, b.sh nếu tồn tại

files_to_delete=("1.sh" "a.sh" "b.sh" "xrayr1.sh")

for file in "${files_to_delete[@]}"; do
    if [ -e "$file" ]; then
        rm "$file" >/dev/null 2>&1  # Xóa file mà không hiển thị output
    fi
done
