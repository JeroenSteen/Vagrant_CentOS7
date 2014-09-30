resources { "firewall":
  purge => true
}

#package {'nginx':
#    ensure => latest
#}
#package {'php5-fpm':
#    ensure => latest
#}

#file { '/etc/nginx/sites-available/default':
#    source => "file:///default"
#}

#file { '/etc/sysconfig/iptables':
#    source => "file:///iptables"
#}