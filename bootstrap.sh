#CentOS7 kickstart
#https://www.centosblog.com/centos-7-minimal-kickstart-file/
#install
#lang en_GB.UTF-8
#keyboard us

#Set timezone Europe/Amsterdam
cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
#Network interface
ifup eth0

#Update YUM package manager; Install packages
yum -y upgrade kernel
yum -y install curl git kernel-devel nano wget
yum groupinstall "Development Tools"

#Install Epel, Remi. Get NGINX, ArangoDB repo
#http://www.rackspace.com/knowledge_center/article/install-the-epel-ius-and-remi-repositories-on-centos-and-red-hat
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
rpm -Uvh https://www.arangodb.org/repositories/arangodb2/CentOS_CentOS-6/x86_64/arangodb-2.2.3-11.1.x86_64.rpm

#Install (Epel)packages
yum -y install nginx nodejs npm mysql mysql-server mariadb-server mariadb phpmyadmin
yum -y --enablerepo=remi install php5 php5-fpm php5-mysql php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache
#Test PHP
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php

#MariaDB with TokuDB
#/usr/bin/mysql_secure_installation
#mysql -u root -p
#Enable TokuDB in MariaDB

#Install Node.JS/NPM packages
npm install -g forever mongodb mongojs nodemon require.io socket.io

#Install MongoDB; todo repo manage file
cp /vagrant/src/mongo.repo /etc/yum.repos.d/mongodb.repo
yum -y install mongodb-org
#Get Semange package provider. Config SELinux for MongoDB
yum -y install policycoreutils-python
semanage port -a -t mongodb_port_t -p tcp 27017

#Install ArangoDB
yum -y install arangodb-2.2.3

#Add host NGINX, firewall Iptables
cp /vagrant/src/iptables /etc/sysconfig/iptables
cp /vagrant/src/default /etc/nginx/sites-available/default
cp /vagrant/src/tokudb /etc/my.cnf

#Cleaning up
yum -y clean all

#Enable: Start at boot, Start/Stop services
firewall-cmd --reload
systemctl enable nginx.service
systemctl start nginx.service
service php5-fpm restart
systemctl enable mariadb.service
systemctl start mariadb.service
service mongod start
chkconfig mongod on
/etc/init.d/arangodb start
chkconfig mysqld on

#nodemon ./server.js localhost 8080
#forever start ./server.js

#Show IP
ifconfig eth0 | grep inet | awk '{ print $2 }'
npm list