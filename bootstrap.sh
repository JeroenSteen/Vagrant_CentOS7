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
yum -y install nginx npm mysql mysql-server
yum --enablerepo=remi install php5-fpm php5-mysql

#Install Node.JS/NPM packages
npm install socket.io require.io mongodb mongojs

#Install MongoDB; todo repo manage file
yum install -y mongodb-org
#Configure SELinux
semanage port -a -t mongodb_port_t -p tcp 27017

#Install ArangoDB
yum install -y arangodb-2.2.3

#Add host NGINX
#chmod 777 /etc/nginx/nginx.conf
#su root nano add "server { listen 80 }" /etc/nginx/nginx.conf

#Cleaning up
yum -y clean all

#Start or Stop services
systemctl enable nginx.service
systemctl start nginx.service
service mongod restart
service php5-fpm restart

#Disable firewall; Voor easy port forward hack
#service iptables stop
#chkconfig iptables off

#Show IP
ifconfig eth0 | grep inet | awk '{ print $2 }'

#Test PHP
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php