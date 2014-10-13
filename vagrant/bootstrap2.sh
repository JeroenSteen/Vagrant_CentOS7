#!/bin/bash

#Variables for User, Password
USER="root"
PASS="test"
#Development (dev), Production (prod)
ENV="dev"
#Set timezone Europe/Amsterdam
sudo cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

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
#Enable TokuDB in MariaDB
#cp /vagrant/src/tokudb /etc/my.cnf
#sudo sed -i "s@\[client-server\]@\[client-server\]\nplugin-load=ha_tokudb@" /etc/my.cnf
#sudo sed -i "s@\[client-server\]@\[client-server\]\nbind-address = 0.0.0.0@" /etc/my.cnf

#Install PhpMyAdmin
sudo yum -y install phpmyadmin
#Link PhpMyAdmin with Nginx symbolicly
sudo ln -s /usr/share/phpMyAdmin /usr/share/nginx/html/
#sudo mv /usr/share/phpMyAdmin /usr/share/nginx/html/
#PhpMyAdmin pass for NGINX
sudo touch /etc/nginx/pma_pass
sudo printf "root:$(openssl passwd -crypt $PASS)\n" >> /etc/nginx/pma_pass
#PhpMyAdmin Multiserver Setup
sudo cp /vagrant/src/config.inc.php /usr/share/phpMyAdmin/config.inc.php
#Config Multiple hosts
sudo cp /vagrant/src/hosts /etc/hosts
sudo sed -i "@#server_names_hash_bucket_size: 64;@server_names_hash_bucket_size: 64;@" /etc/nginx/nginx.conf
#https://www.digitalocean.com/community/tutorials/how-to-configure-vsftpd-to-use-ssl-tls-on-a-centos-vps

#Make Group for SFTP
sudo groupadd sftpusers
sudo useradd -g sftpusers vagrant
#Make Website folder and SFTP Users
JS_WWW="/usr/share/nginx/html/jeroensteen"
sudo useradd -g sftpusers -d $JS_WWW -s /sbin/nologin -p jeroensteen jeroensteen
sudo chown jeroensteen:sftpusers $JS_WWW
sudo chown nginx:nginx $JS_WWW
sudo cp /vagrant/src/www/index_js.html $JS_WWW/index.html

TH_WWW="/usr/share/nginx/html/theohuson"
sudo useradd -g sftpusers -d $TH_WWW -s /sbin/nologin -p theohuson theohuson
sudo chown theohuson:sftpusers $TH_WWW
sudo chown nginx:nginx $TH_WWW
sudo cp /vagrant/src/www/index_th.html $TH_WWW/index.html

OM_WWW="/usr/share/nginx/html/omnivoor"
sudo useradd -g sftpusers -d $OM_WWW -s /sbin/nologin -p omnivoor omnivoor
sudo chown omnivoor:sftpusers $OM_WWW
sudo chown nginx:nginx $OM_WWW
sudo cp /vagrant/src/www/index_om.html $OM_WWW/index.html

MO_WWW="/usr/share/nginx/html/matcheo"
sudo useradd -g sftpusers -d $MO_WWW -s /sbin/nologin -p matcheo matcheo
sudo chown matcheo:sftpusers $MO_WWW
sudo chown nginx:nginx $MO_WWW
sudo cp /vagrant/src/www/index_mo.html $MO_WWW/index.html

KS_WWW="/usr/share/nginx/html/kunststructuur"
sudo useradd -g sftpusers -d $KS_WWW -s /sbin/nologin -p kunststructuur kunststructuur
sudo chown kunststructuur:sftpusers $KS_WWW
sudo chown nginx:nginx $KS_WWW
sudo cp /vagrant/src/www/index_ks.html $KS_WWW/index.html

#Change Shell for User; sudo chsh -s /bin/bash username
#http://community.spiceworks.com/scripts/show/1799-adding-sftp-users

#Configure SFTP
#http://www.server-world.info/en/note?os=CentOS_7&p=ssh&f=5
sudo sed -i "s@/usr/libexec/openssh/sftp-server@internal-sftp@" /etc/ssh/sshd_config
sudo echo "Match Group sftpusers" > /etc/ssh/sshd_config
sudo echo "	ChrootDirectory /usr/share/nginx/html/%u" > /etc/ssh/sshd_config
sudo echo "	ForceCommand internal-sftp" > /etc/ssh/sshd_config
sudo systemctl restart sshd

#Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/home
mkdir /usr/local/bin/composer
mv /home/composer.phar /usr/local/bin/composer

#Install Node.JS/NPM packages
yum -y --enablerepo=epel install nodejs npm
#Get registry for NPM packages
sudo npm config set registry http://registry.npmjs.org/
#Install Node packages
npm install -g forever --save
npm install -g mongodb --save
npm install -g mongojs --save
npm install -g nodemon --save
npm install -g require --save
npm install -g express --save
npm install -g socket.io --save

#Install MongoDB, from Repo file
yum -y install mongodb-org-2.6.3
#Get Semange package provider. Config SELinux for MongoDB
yum -y install policycoreutils-python
semanage port -a -t mongodb_port_t -p tcp 27017
#Make fix version
#"exclude=mongodb-org" > /etc/yum.conf
#Purging config
#db.chat.update({},{$set: {created_at: new Date()}}, false, true)
#db.chat.ensureIndex( { "created_at": 1 }, { expireAfterSeconds: 3600 } )
#db.runCommand({"collMod" : "chat" , "index" : { "keyPattern" : {"created_at" : 1 } , "expireAfterSeconds" : 31536000 } })

#Install ArangoDB
yum -y install arangodb-2.2.3
#https://github.com/triAGENS/ArangoDB/blob/master/Documentation/man/man8/arangod.8
#https://www.arangodb.org/manuals/2/install-manual.pdf
#cd ArangoDB && make setup

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

#No prompt for setting MariaDB pass
sudo mysqladmin -u root password $PASS
#Do User setup
sudo mysql --user=$USER --password=$PASS < /vagrant/src/users.sql
#Remove SQL file
if [ $ENV == "prod" ]; then sudo rm -f /vagrant/src/users.sql; fi

#Install and Config Cronjobs
#sudo yum -y install vixie-cron crontabs
#sudo /sbin/chkconfig crond on
#sudo /sbin/service crond start
#crontab -e > @monthly php artisan spotlight:make
#echo ALL >>/etc/cron.deny
#echo root >>/etc/cron.allow

#HWADDR="ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'"
#IPADDR="192.168.1.666"
#IPROUTER="192.168.1.254"

#Config Eth0
#sudo echo "DEVICE=eth0
#BOOTPROTO=static
#IPADDR=$IPADDR
#NETMASK=255.255.255.0
#GATEWAY=$IPROUTER
#DNS1=$IPROUTER
#DNS2=$IPROUTER
#USERCTL=yes
#HWADDR= $HWADDR
#ONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth0
#http://www.yolinux.com/TUTORIALS/LinuxTutorialNetworking.html

#Add Static, Google IP; DNS/Nameservers
#sudo echo "" > /etc/resolv.conf
#Add Gateway to network
#sudo echo "GATEWAY = $IPROUTER" > /etc/sysconfig/network
#Restart network
#/etc/init.d/network restart

#MAKE SSH KEY: https://help.github.com/articles/generating-ssh-keys/
#ssh-keygen -t rsa -C "jeo_recordz@hotmail.com"
#Start SSH Agent
#ssh-agent -s
#Add SSH key toAgent pid 59566
#ssh-add ~/.ssh/id_rsa
 
#DEPLOY: http://stackoverflow.com/questions/23391839/clone-private-git-repo-with-dockerfile
#Make SSH dir
#mkdir /root/.ssh/
 
#Add private key in SSH dir
#cp /vagrant/src/id_rsa /root/.ssh/id_rsa
 
#Create known hosts
#touch /root/.ssh/known_hosts
#Add bitbuckets key to known hosts
#ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
 
#Clone the conf files into www folder
#git clone git@bitbucket.org:User/repo.git
