#!/bin/bash

echo -n "Nhập token trên web vps.dualeovpn.net: "
read token

curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh
chmod +x nezha.sh
sudo ./nezha.sh install_agent vps1.dualeovpn.net 5555 $token
