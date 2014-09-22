include motd

file { 'motd':
	path    => '/etc/motd',
    content => template('site/motd'),
}