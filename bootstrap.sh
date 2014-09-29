#CentOS7 kickstart
#https://www.centosblog.com/centos-7-minimal-kickstart-file/

#Set timezone Europe/Amsterdam
cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

#Use DeltaRPM; yum provides '*/applydeltarpm'
yum -y install deltarpm-3.6-3.el7.x86_64
#Update YUM package manager
yum -y upgrade kernel
yum -y --enablerepo=base clean metadata
#Install packages
yum -y install curl curl-devel git kernel-devel nano wget
yum -y groupinstall "Development Tools"

#Install GUI
#yum -y groupinstall "GNOME Desktop" "Graphical Administration Tools"
#ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target

#Use Repositories: Remi, Epel, NGINX, ArangoDB. Maybe IUS, Ajenti
#Get Remi dependency Epel; CentOS 7 and Red Hat (RHEL) 7
#http://dl.fedoraproject.org/pub/epel/7/x86_64/e/
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
#Get Remi repo; CentOS 7 and Red Hat (RHEL) 7
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
#Get NGINX
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
#Get ArangoDB
rpm -Uvh https://www.arangodb.org/repositories/arangodb2/CentOS_CentOS-6/x86_64/arangodb-2.2.3-11.1.x86_64.rpm
#Add Repositories; update YUM
cp /vagrant/src/nginx.repo /etc/yum.repos.d/nginx.repo
cp /vagrant/src/mongo.repo /etc/yum.repos.d/mongodb.repo
cp /vagrant/src/mariadb.repo /etc/yum.repos.d/mariadb.repo
#Disable MariaDB 5 in Repo for MariaDB 10
echo 'exclude=mariadb' >> /etc/yum.repos.d/CentOS-Base.repo
yum -y update
yum -y clean all

#Install NGINX, PHP 5.4 packages
#php5 php5-fpm php5-mysql php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache
#yum -y --enablerepo=remi,remi-php56 install nginx php-fpm php-common php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo php-pecl-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
yum -y install nginx php-fpm php-common
yum -y install php-cli php-gd php-ldap php-mbstring php-mcrypt php-mysqlnd php-odbc php-opcache php-pdo php-pear php-pecl-apcu php-pecl-memcache php-pecl-memcached php-pecl-mongo php-pecl-sqlite php-pgsql php-snmp php-soap php-xml php-xmlrpc
#Make log files; NGINX
mkdir /var/log/nginx/
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
#Config NGINX; Default host
cp /vagrant/src/default /etc/nginx/conf.d/default.conf
#Config PHP-FPM
#https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
#sudo sed -i "s@worker_processes 1;@worker_processes 4;" /etc/nginx/nginx.conf
#sudo sed -i "s@worker_connections 1024;@worker_connections 2048;" /etc/nginx/nginx.conf
sudo sed -i "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=0@" /etc/php.ini
sudo sed -i 's@;date.timezone =@date.timezone = "Europe/Amsterdam"@' /etc/php.ini
#sudo sed -i '@max_connect_errors=100@max_connect_errors=5000@' /etc/php.ini
sudo sed -i "s@listen = 127.0.0.1:9000@listen = /var/run/php-fpm/php-fpm.sock@" /etc/php-fpm.d/www.conf
sudo sed -i "s@;listen.owner = nobody@listen.owner = nginx@" /etc/php-fpm.d/www.conf
sudo sed -i "s@;listen.group = nobody@listen.group = nginx@" /etc/php-fpm.d/www.conf
sudo sed -i "s@user = apache@user = nginx@" /etc/php-fpm.d/www.conf
sudo sed -i "s@group = apache@group = nginx@" /etc/php-fpm.d/www.conf
#Test PHP
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php

#Install MariaDB with TokuDB, PHPMyAdmin
#https://registry.hub.docker.com/u/zhaowh/centos-mariadb/dockerfile/
#yum -y install mariadb-server mariadb phpmyadmin --skip-broken
#Remove MariaDB 5
yum -y remove mariadb-libs
#Install MariaDB 5
#yum -y install mariadb-server mariadb
#Install MariaDB 10
yum -y install MariaDB-client MariaDB-common MariaDB-compat MariaDB-devel MariaDB-server MariaDB-shared phpmyadmin
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

#Link PhpMyAdmin with Nginx symbolicly
ln -s /usr/share/phpMyAdmin /usr/share/nginx/html
#https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-a-centos-7-server

#No prompt at setting MariaDB pass
#export DEBIAN_FRONTEND=noninteractive
#debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password db_password rootpass' 2x
#debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/vagrant test vagrant'
#debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/vagrant test vagrant'
#mysql -uroot -pPASS -e "SET PASSWORD FOR 'root' = PASSWORD('test');"
#Make pass for MariaDB
mysqladmin -u root password test
#mysql -u root -p
#http://jetpackweb.com/blog/2009/07/20/bash-script-to-create-mysql-database-and-user/

#cp /usr/share/mysql/mysql.server /etc/init.d/mysql, /var/lib/mysql/mysql.sock
#chmod +x /etc/init.d/mysql
#chkconfig --add mysql
#chkconfig --level 345 mysql on
#Make log files; MariaDB
mkdir /var/log/mariadb
touch /var/log/mariadb/mariadb.log
#chown -R mysql:mysql /var/lib/mysql
#Enable TokuDB in MariaDB
#cp /vagrant/src/tokudb /etc/my.cnf
#sudo sed -i "s@\[client-server\]@\[client-server\]\nplugin-load=ha_tokudb@" /etc/my.cnf
#mysql -u root -p
#MariaDB > SHOW VARIABLES;
#MariaDB > quit

#Install Node.JS/NPM packages
yum -y --enablerepo=epel install nodejs npm
sudo npm config set registry http://registry.npmjs.org/
npm install -g forever --save
npm install -g mongodb --save
npm install -g mongojs --save
npm install -g nodemon --save
npm install -g require --save
npm install -g express --save
npm install -g socket.io --save

#Install MongoDB; Repo file
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

#Add Iptables; firewall rules
cp /vagrant/src/iptables /etc/sysconfig/iptables

#Cleaning up
yum -y clean all

#Autostart, Start/Stop services
systemctl restart firewalld.service
#firewall-cmd --reload
#Start NGINX
systemctl enable nginx.service
systemctl start nginx.service
#Start PHP-FPM
systemctl enable php-fpm.service
systemctl start php-fpm.service
#Start MariaDB
#/etc/init.d/mysql start, mysql/mariadb
systemctl enable mysql.service
systemctl start mysql.service
#Start MongoDB
service mongod start
chkconfig mongod on
#Start ArangoDB
/etc/init.d/arangodb start
#chkconfig mysqld on
#nodemon ./server.js localhost 8080
#forever start ./server.js

#Show IP
ifconfig eth0 | grep inet | awk '{ print $2 }'
#Show node packages
npm list -g
#SELinux status ect.
sestatus -v