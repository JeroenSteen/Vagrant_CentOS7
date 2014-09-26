#CentOS7 kickstart
#https://www.centosblog.com/centos-7-minimal-kickstart-file/

#Set timezone Europe/Amsterdam
cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

#Update YUM package manager; Install DeltaRPM
yum -y upgrade kernel
yum -y --enablerepo=base clean metadata
#yum provides '*/applydeltarpm'
yum -y install deltarpm-3.6-3.el7.x86_64
#Install packages
yum -y install curl git kernel-devel nano wget
yum -y groupinstall "Development Tools"

#Install GUI
#yum -y groupinstall "GNOME Desktop" "Graphical Administration Tools"
#ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target

#Remi, Epel, NGINX, ArangoDB. Maybe IUS
#Get Remi dependency Epel; CentOS 7 and Red Hat (RHEL) 7
#http://dl.fedoraproject.org/pub/epel/7/x86_64/e/
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
#Get Remi repo; CentOS 7 and Red Hat (RHEL) 7
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
#Get NGINX
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
#Get ArangoDB
rpm -Uvh https://www.arangodb.org/repositories/arangodb2/CentOS_CentOS-6/x86_64/arangodb-2.2.3-11.1.x86_64.rpm

#Install packages
#php5 php5-fpm php5-mysql php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache
#yum -y --enablerepo=remi,remi-php56 install nginx php-fpm php-common php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo php-pecl-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
cp /vagrant/src/nginx.repo /etc/yum.repos.d/nginx.repo
yum -y --enablerepo=remi,remi-php56 install nginx php-fpm php-common
yum -y --enablerepo=remi,remi-php56 install php-cli php-gd php-mbstring php-mcrypt php-mysqlnd php-opcache php-pdo php-pear php-pecl-apcu php-pecl-memcache php-pecl-memcached php-pecl-mongo php-pecl-sqlite php-pgsql php-xml
sudo sed -i "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=0@" /etc/php.ini
sudo sed -i "s@listen = 127.0.0.1:9000@/var/run/php-fpm/php-fpm.sock@" /etc/php-fpm.d/www.conf
sudo sed -i "s@user = apache@user = nginx@" /etc/nginx/nginx.conf
sudo sed -i "s@group = apache@group = nginx@" /etc/nginx/nginx.conf

yum -y mysql mysql-server mariadb-server mariadb phpmyadmin
#Make log files
mkdir /var/log/nginx/
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
#Test PHP
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php
#MariaDB with TokuDB
#/usr/bin/mysql_secure_installation
#mysql -u root -p
#Enable TokuDB in MariaDB

#Install Node.JS/NPM packages
yum -y --enablerepo=epel install nodejs npm
sudo npm config set registry http://registry.npmjs.org/
npm install -g forever --save
npm install -g mongodb --save
npm install -g mongojs --save
npm install -g nodemon --save
npm install -g require.io --save
npm install -g socket.io --save

#Install MongoDB; Repo file
cp /vagrant/src/mongo.repo /etc/yum.repos.d/mongodb.repo
yum -y install mongodb-org
#Get Semange package provider. Config SELinux for MongoDB
yum -y install policycoreutils-python
semanage port -a -t mongodb_port_t -p tcp 27017

#Install ArangoDB
yum -y install arangodb-2.2.3

#Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/home
mkdir /usr/local/bin/composer
mv /home/composer.phar /usr/local/bin/composer

#Add host NGINX, firewall Iptables
cp /vagrant/src/iptables /etc/sysconfig/iptables
#cp /vagrant/src/default /etc/nginx/sites-available/default
cp /vagrant/src/default /etc/nginx/conf.d/default.conf
cp /vagrant/src/tokudb /etc/my.cnf

#Cleaning up
yum -y clean all

#Autostart, Start/Stop services
systemctl restart firewalld.service
#firewall-cmd --reload
systemctl enable nginx.service
systemctl start nginx.service

systemctl enable php-fpm.service
systemctl start php-fpm.service

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
#Show node packages
npm list -g
#SELinux status ect.
sestatus -v