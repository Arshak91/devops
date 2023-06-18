#!/bin/bash


sudo apt update
sudo apt install nginx -y

sudo systemctl enable nginx

sudo touch /var/www/html/index.html

echo "<html><body>Hello World</body></html>"> /var/www/html/index.html

curl -4 icanhazip.com


