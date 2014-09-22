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
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
rpm -Uvh https://www.arangodb.org/repositories/arangodb2/CentOS_CentOS-6/x86_64/arangodb-2.2.3-11.1.x86_64.rpm

#Install (Epel)packages
yum -y install nginx nodejs npm mysql mysql-server phpmyadmin
yum --enablerepo=remi install php5-fpm php5-mysql php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

#Install Node.JS/NPM packages
npm install forever mongodb mongojs nodemon require.io socket.io

#Install MongoDB; todo repo manage file
cp /vagrant/src/mongo.repo /etc/yum.repos.d/mongodb.repo
yum install -y mongodb-org
#Configure SELinux
semanage port -a -t mongodb_port_t -p tcp 27017

#Install ArangoDB
yum install -y arangodb-2.2.3

#Disable firewall; Voor easy port forward hack
#service iptables stop
#chkconfig iptables off

#Add host NGINX, Iptables
#chmod 777 /etc/nginx/nginx.conf
#chmod 777 /etc/sysconfig/iptables
#sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini
#mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
cp /vagrant/src/default /etc/nginx/sites-available/default
cp /vagrant/src/iptables /etc/sysconfig/iptables

#Cleaning up
yum -y clean all

#Start or Stop services
systemctl enable nginx.service
systemctl start nginx.service
service mongod start
chkconfig mongod on
service php5-fpm restart
/etc/init.d/arangodb start
#nodemon ./server.js localhost 8080
#forever start ./server.js

#Show IP
ifconfig eth0 | grep inet | awk '{ print $2 }'

#Test PHP
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php