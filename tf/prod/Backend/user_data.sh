#!/bin/sh
sudo yum update
sudo yum remove mariadb-*
sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el9-3.noarch.rpm
sudo yum install -y --enablerepo=mysql80-community mysql-community-server
sudo yum install -y --enablerepo=mysql80-community mysql-community-devel