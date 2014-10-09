<?php
//PhpMyAdmin Multiserver Setup
//https://wiki.phpmyadmin.net/pma/Multiserver
//https://wiki.phpmyadmin.net/pma/Quick_Install#Manually

//String of choice; max. 46 characters
$cfg['blowfish_secret']='fishey';
$i = 0;  


$i++; // server 1 :
$cfg['Servers'][$i]['auth_type'] = 'cookie'; // needed for pma 2.x
$cfg['Servers'][$i]['verbose']   = 'no1'; 
$cfg['Servers'][$i]['host']      = 'localhost';
$cfg['Servers'][$i]['extension'] = 'mysqli';
// more options for #1 ...


#$i++; // server 2 :
#$cfg['Servers'][$i]['auth_type'] = 'cookie';
#$cfg['Servers'][$i]['verbose']   = 'no2'; 
#$cfg['Servers'][$i]['host']      = 'remote.host.addr';//or ip:'10.9.8.1'
//Server must allow remote clients, e.g., host 10.9.8.%
// not only in mysql.host but also in the startup configuration
#$cfg['Servers'][$i]['extension'] = 'mysqli';


//End of server sections
$cfg['ServerDefault'] = 0; // to choose the server on startup

?>