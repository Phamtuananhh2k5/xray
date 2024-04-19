sudo renice 50 -p 13
sudo renice 50 -p 22
echo -n "Chọn mã server (A, B, C, D, E):  "
read option
option=$(echo "$option" | tr '[:upper:]' '[:lower:]')  # Chuyển đổi thành chữ thường

case $option in
  a) bash <(curl -Ls https://raw.githubusercontent.com/Panhuqusyxh/xrayra/master/aws1.sh);;
  b) bash <(curl -Ls https://raw.githubusercontent.com/Panhuqusyxh/xrayra/master/aws2.sh);;
  c) bash <(curl -Ls https://raw.githubusercontent.com/Panhuqusyxh/xrayra/master/aws3.sh);;
  d) bash <(curl -Ls https://raw.githubusercontent.com/Panhuqusyxh/xrayra/master/aws4.sh);;
  e) bash <(curl -Ls https://raw.githubusercontent.com/Panhuqusyxh/xrayra/master/aws5.sh);;
  *) echo "Lỗi yêu cầu kiểm tra lại"; exit 1;;
esac
