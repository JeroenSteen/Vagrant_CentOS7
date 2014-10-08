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
sudo cp /vagrant/src/default.conf /etc/nginx/conf.d/default.conf

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

#Import MariaDB key
sudo rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
#Remove MariaDB 5
sudo yum -y remove mariadb-libs
#Install MariaDB 10
sudo yum -y install MariaDB-client MariaDB-common MariaDB-compat MariaDB-devel MariaDB-server MariaDB-shared
#Make log files; MariaDB
sudo mkdir /var/log/mariadb
sudo touch /var/log/mariadb/mariadb.log
#No prompt for setting MariaDB pass
mysqladmin -u root password $PASS
#Set Root User Password for all Local domains
#sudo mysql --user=$USER --password=$PASS -e "SET PASSWORD FOR 'root@localhost' = PASSWORD('appel');"
#sudo mysql --user=$USER --password=$PASS -e "SET PASSWORD FOR 'root@127.0.0.1' = PASSWORD('appel');"
#sudo mysql --user=$USER --password=$PASS -e "SET PASSWORD FOR 'root@::1' = PASSWORD('appel');"
#Drop the Any User
#sudo mysql --user=$USER --password=$PASS -e "DROP USER ''@'localhost';"
#http://www.websightdesigns.com/posts/view/how-to-configure-an-ubuntu-web-server-vm-with-vagrant
#SET @t1=1
#echo -n password | sha256sum | awk '{print toupper($1)}'

#Install PhpMyAdmin
yum -y install phpmyadmin
#Link PhpMyAdmin with Nginx symbolicly
sudo ln -s /usr/share/phpMyAdmin /usr/share/nginx/html/
#sudo mv /usr/share/phpMyAdmin /usr/share/nginx/html/
#PhpMyAdmin pass for NGINX
sudo touch /etc/nginx/pma_pass
sudo printf "root:$(openssl passwd -crypt $PASS)\n" >> /etc/nginx/pma_pass

#Config Multiple hosts
#sudo cp /vagrant/src/hosts /etc/hosts
#Prepare www folder
sudo mkdir /usr/share/nginx/html/js
sudo mkdir /usr/share/nginx/html/th
sudo mkdir /usr/share/nginx/html/om
sudo mkdir /usr/share/nginx/html/mo
sudo mkdir /usr/share/nginx/html/ks

#Start NGINX
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
#Start PHP-FPM
sudo systemctl enable php-fpm.service
sudo systemctl start php-fpm.service
#Start Firewall daemon
sudo systemctl enable firewalld.service
sudo systemctl start firewalld.service
#Start MariaDB
sudo systemctl enable mysql.service
sudo systemctl start mysql.service

#Set firewall rules
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
sudo firewall-cmd --permanent --zone=public --add-service=mysql
#Reload firewall
sudo firewall-cmd --reload