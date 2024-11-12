#!/bin/bash

# Kiểm tra sự tồn tại của file xrayrpro.sh
if [ -e "xrayrpro.sh" ]; then
    echo "Đã tìm thấy xrayrpro.sh. Đang xóa..."
    rm xrayrpro.sh
    echo "Đã xóa xrayrpro.sh"
else
    echo "Không tìm thấy xrayrpro.sh"
fi

# Kiểm tra sự tồn tại của file xrayr.sh
if [ -e "xrayr.sh" ]; then
    echo "Đã tìm thấy xrayr.sh. Đang xóa..."
    rm xrayr.sh
    echo "Đã xóa xrayr.sh"
else
    echo "Không tìm thấy xrayr.sh"
fi

clear
echo ""
echo "   1. Cài đặt"
echo "   2. update config"
echo "   3. thêm node"
read -p "   Lựa chọn của bạn là (mặc định Cài đặt): " num
[ -z "${num}" ] && num="1"
    
pre_install(){
 clear
    read -p "  Nhập số Node cần cài (mặc định 1): " n
     [ -z "${n}" ] && n="1"
    a=0
  while [ $a -lt $n ]
 do
read -p "  Nhập domain web (không cần https://, Enter để sử dụng mặc định api.thanhthanh.site): " api_host
[ -z "${api_host}" ] && api_host="api.thanhthanh.site"
echo "--------------------------------"
echo "  Web của bạn là https://${api_host}"
echo "--------------------------------"

# Key web
read -p "  Nhập key của web (Enter để sử dụng mặc định dualeovpndualeovpn): " api_key
[ -z "${api_key}" ] && api_key="dualeovpndualeovpn"
echo "--------------------------------"
echo "  Key của Web là ${api_key}"
echo "--------------------------------"

  echo -e "  [1] V2ray"
  echo -e "  [2] Trojan"  
  echo -e "  [3] Shadowsocks"
   read -p "  Nhập loại Node: " NodeType
  if [ "$NodeType" == "1" ]; then
    NodeType="V2ray"
  elif [ "$NodeType" == "2" ]; then
    NodeType="Trojan"
  elif [ "$NodeType" == "3" ]; then
    NodeType="Shadowsocks"
  else 
   NodeType="V2ray"
  fi
  echo "-------------------------------"
  echo -e "  Loại Node là ${NodeType}"
  echo "-------------------------------"


  #node id
    read -p "  Nhập ID Node: " node_id
  [ -z "${node_id}" ] && node_id=0
  echo "-------------------------------"
  echo -e "  ID Node là ${node_id}"
  echo "-------------------------------"
  

  #giới hạn thiết bị
read -p "  Nhập giới hạn thiết bị: " DeviceLimit
  [ -z "${DeviceLimit}" ] && DeviceLimit="0"
  echo "-------------------------------"
  echo "  Thiết bị tối đa là ${DeviceLimit}"
  echo "-------------------------------"
  
  
  #IP vps
 read -p "  Nhập IP or Domain Node: " CertDomain
  [ -z "${CertDomain}" ] && CertDomain="0"
 echo "-------------------------------"
  echo "  Địa chỉ Node là ${CertDomain}"
 echo "-------------------------------"

 config
  a=$((a+1))
done
}


#clone node
clone_node(){
  clear
    read -p "  Nhập số Node cần cài thêm (mặc định 1): " n
     [ -z "${n}" ] && n="1"
    a=0
  while [ $a -lt $n ]
  do
  
  #link web 
read -p "  Nhập domain web (không cần https://, Enter để sử dụng mặc định api.thanhthanh.site): " api_host
[ -z "${api_host}" ] && api_host="api.thanhthanh.site"
echo "--------------------------------"
echo "  Web của bạn là https://${api_host}"
echo "--------------------------------"

# Key web
read -p "  Nhập key của web (Enter để sử dụng mặc định dualeovpndualeovpn): " api_key
[ -z "${api_key}" ] && api_key="dualeovpndualeovpn"
echo "--------------------------------"
echo "  Key của Web là ${api_key}"
echo "--------------------------------"

  echo -e "  [1] V2ray"
  echo -e "  [2] Trojan"  
  echo -e "  [3] Shadowsocks"
   read -p "  Nhập loại Node: " NodeType
  if [ "$NodeType" == "1" ]; then
    NodeType="V2ray"
  elif [ "$NodeType" == "2" ]; then
    NodeType="Trojan"
  elif [ "$NodeType" == "3" ]; then
    NodeType="Shadowsocks"
  else 
   NodeType="V2ray"
  fi
  echo "-------------------------------"
  echo -e "  Loại Node là ${NodeType}"
  echo "-------------------------------"


  #node id
    read -p "  Nhập ID Node: " node_id
  [ -z "${node_id}" ] && node_id=0
  echo "-------------------------------"
  echo -e "  ID Node là ${node_id}"
  echo "-------------------------------"
  

  #giới hạn thiết bị
read -p "  Nhập giới hạn thiết bị: " DeviceLimit
  [ -z "${DeviceLimit}" ] && DeviceLimit="0"
  echo "-------------------------------"
  echo "  Thiết bị tối đa là ${DeviceLimit}"
  echo "-------------------------------"
  
  #IP vps
 read -p "  Nhập IP or Domain Node: " CertDomain
  [ -z "${CertDomain}" ] && CertDomain="0"
 echo "-------------------------------"
  echo "  Địa chỉ Node là ${CertDomain}"
 echo "-------------------------------"

 config
  a=$((a+1))
  done
}







config(){
cd /etc/XrayR
cat >>config.yml<<EOF
  -
    PanelType: "V2board" # Panel type: SSpanel, V2board, PMpanel, Proxypanel, V2RaySocks
    ApiConfig:
      ApiHost: "https://$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: $NodeType # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: $DeviceLimit # Local settings will replace remote settings, 0 means disable
      RuleListPath: # /etc/XrayR/rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: AsIs # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      DisableUploadTraffic: false # Disable Upload Traffic to the panel
      DisableGetRule: false # Disable Get Rule from the panel
      DisableIVCheck: false # Disable the anti-reply protection for Shadowsocks
      DisableSniffing: True # Disable domain sniffing
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      AutoSpeedLimitConfig:
        Limit: 0 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 0 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 0 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 0 # How many minutes will the limiting last (unit: minute)
      GlobalDeviceLimitConfig:
        Limit: 0 # The global device limit of a user, 0 means disable
        RedisAddr: 127.0.0.1:6379 # The redis server address
        RedisPassword: YOUR PASSWORD # Redis password
        RedisDB: 0 # Redis DB
        Timeout: 5 # Timeout for redis request
        Expiry: 60 # Expiry time (second)
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Alpn: # Alpn, Empty for any
          Path: # Path, Empty for any
        -
          SNI: "v2ray.com"
          Alpn: "h2"
          Path: "vless"

EOF
}

install_script(){
curl -sSL https://api.thanhthanh.site/install.sh | bash
}

if [ "$num" == "1" ]; then
    pre_install
elif [ "$num" == "2" ]; then
    clone_node
elif [ "$num" == "3" ]; then
    install_script
fi
