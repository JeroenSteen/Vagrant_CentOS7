#!/bin/bash

#Variables for User, Password
USER="root"
PASS="test"
#Set timezone Europe/Amsterdam
cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

#Use DeltaRPM; /usr/bin/applydeltarpm
sudo yum -y install deltarpm.x86_64
#Update Linux Kernel
sudo yum -y upgrade kernel
#Prevent upgrade Linux Kernel
sudo yum -y -x 'kernel*' update

#Install tools; dkms
sudo yum -y install curl curl-devel git wget nano
sudo yum -y groupinstall "Development Tools"
sudo yum -y install kernel-devel

#Install Epel repo; 7.2
sudo yum -y install epel-release
#Get Remi repo, needs Epel
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

#Add NGINX Repo
sudo cp /vagrant/src/nginx.repo /etc/yum.repos.d/nginx.repo
#Add ArangoDB Repo
sudo cp /vagrant/src/arangodb.repo /etc/yum.repos.d/arangodb.repo
#Add MongoDB Repo
sudo cp /vagrant/src/mongodb.repo /etc/yum.repos.d/mongodb.repo
#Add MariaDB 10 Repo
sudo cp /vagrant/src/mariadb.repo /etc/yum.repos.d/mariadb.repo
#Disable MariaDB 5 in Base Repo, for MariaDB 10
sudo echo 'exclude=mariadb' >> /etc/yum.repos.d/CentOS-Base.repo
#Update Repo data
sudo yum -y clean metadata
sudo yum -y update

#Install NGINX
sudo yum -y install nginx
#Make log files; NGINX
sudo mkdir /var/log/nginx/
sudo touch /var/log/nginx/access.log
sudo touch /var/log/nginx/error.log
#Config NGINX
#sudo sed -i "s@worker_processes 1;@worker_processes 4;" /etc/nginx/nginx.conf
#sudo sed -i "s@worker_connections 1024;@worker_connections 2048;" /etc/nginx/nginx.conf
#Config Default host
sudo cp /vagrant/src/default2.conf /etc/nginx/conf.d/default.conf

#Install PHP 5.4
sudo yum -y install php-fpm php-common
#Install PHP 5.4 packages
sudo yum -y install php-cli php-gd php-ldap php-mbstring php-mcrypt php-mysqlnd php-odbc php-opcache php-pdo php-pear php-pecl-apcu php-pecl-memcache php-pecl-memcached php-pecl-mongo php-pecl-sqlite php-pgsql php-snmp php-soap php-xml php-xmlrpc
#Config PHP
sudo sed -i "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=0@" /etc/php.ini
sudo sed -i 's@;date.timezone =@date.timezone = "Europe/Amsterdam"@' /etc/php.ini
#sudo sed -i '@max_connect_errors=100@max_connect_errors=5000@' /etc/php.ini
#Config PHP-FPM
sudo sed -i "s@listen = 127.0.0.1:9000@listen = /var/run/php-fpm/php-fpm.sock@" /etc/php-fpm.d/www.conf
sudo sed -i "s@;listen.owner = nobody@listen.owner = nginx@" /etc/php-fpm.d/www.conf
sudo sed -i "s@;listen.group = nobody@listen.group = nginx@" /etc/php-fpm.d/www.conf
sudo sed -i "s@user = apache@user = nginx@" /etc/php-fpm.d/www.conf
sudo sed -i "s@group = apache@group = nginx@" /etc/php-fpm.d/www.conf
#Test PHP
sudo echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php
sudo cp /vagrant/src/db_test.php /usr/share/nginx/html/db_test.php

#PhpMyAdmin pass for NGINX
sudo touch /etc/nginx/pma_pass
sudo printf "root:$(openssl passwd -crypt $PASS)\n" >> /etc/nginx/pma_pass

#Config Multiple hosts
sudo cp /vagrant/src/hosts /etc/hosts
#Prepare www folder
mkdir /usr/share/nginx/html/js
mkdir /usr/share/nginx/html/th
mkdir /usr/share/nginx/html/om
mkdir /usr/share/nginx/html/mo
mkdir /usr/share/nginx/html/ks

#Add Iptables; firewall rules
sudo cp /vagrant/src/iptables /etc/sysconfig/iptables

#Autostart, Start/Stop services
systemctl restart firewalld.service
#firewall-cmd --reload
#Start NGINX
systemctl enable nginx.service
systemctl start nginx.service
#Start PHP-FPM
systemctl enable php-fpm.service
systemctl start php-fpm.service

#netstat -an | find "8080"
#netstat -o -n -a | findstr 0.0:8080
#taskkill /PID 3416