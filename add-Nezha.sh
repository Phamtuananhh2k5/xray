#!/bin/bash

echo -n "Nhập token trên web vps.dualeovpn.net: "
read token

curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh
chmod +x nezha.sh
sudo ./nezha.sh install_agent 103.69.128.95 5555 $token
