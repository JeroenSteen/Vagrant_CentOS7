#Password variable
SET @username="root";
SET @password="secret";

#Remove non Root Users
DELETE FROM mysql.user WHERE User != "root";
#Drop the Any User
DROP USER ''@'localhost';

#Set Root User Password for all Local domains
#SET PASSWORD FOR 'root@localhost' = PASSWORD(password);
#SET PASSWORD FOR 'root@127.0.0.1' = PASSWORD(password);
#SET PASSWORD FOR 'root@::1' = PASSWORD(password);

#SET Password=PASSWORD(password) WHERE User="root";
UPDATE mysql.user SET Password=PASSWORD(@password) WHERE User=@username;

#CREATE USER test@localhost IDENTIFIED BY 'passpass';
#grant all privileges on *.* to test@localhost with grant option;
FLUSH PRIVILEGES;