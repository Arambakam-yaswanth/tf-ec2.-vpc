#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo rm -rf /var/www/html/*
sudo git clone https://github.com/Arambakam-yaswanth/login-2433.git /var/www/html