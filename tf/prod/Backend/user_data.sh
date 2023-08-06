#!/bin/sh
sudo yum update

#install mysql
sudo yum remove mariadb-*
sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el9-3.noarch.rpm
sudo yum install -y --enablerepo=mysql80-community mysql-community-server
sudo yum install -y --enablerepo=mysql80-community mysql-community-devel

# setting NAT instance
# https://dev.classmethod.jp/articles/how-to-create-amazon-linux-2023-nat-instance/
sudo sysctl -w net.ipv4.ip_forward=1 | sudo tee -a /etc/sysctl.conf
# Amazon Linux 2023の初期状態ではiptablesは未インストール
# このため今回はnftablesをインストール
sudo yum install -y nftables
sudo nft add table nat
sudo nft -- add chain nat prerouting { type nat hook prerouting priority -100 \; }
sudo nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
sudo nft add rule nat postrouting oifname "$(ip -o link show device-number-0 | awk -F': ' '{print $2}')" masquerade
# NAT設定保存
sudo nft list table nat | sudo tee /etc/nftables/al2023-nat.nft
echo 'include "/etc/nftables/al2023-nat.nft"' | sudo tee -a /etc/sysconfig/nftables.conf

# サービス起動＋自動起動設定
sudo systemctl start nftables
sudo systemctl enable nftables