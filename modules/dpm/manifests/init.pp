# init.pp

group { 'dpmmgr': gid => 151, ensure => present }
user { 'dpmmgr': comment => 'dpm manager', uid => 151, gid => 'dpmmgr', ensure => present }

class dpm::dpm {
	service { 'dpm':
		subscribe => File['dpm-config', 'dpm-sysconfig'],
		ensure => running,
	}
	file { 'dpm-config':
		path => $operatingsytem ? {
			default => '/opt/lcg/etc/DPMCONFIG',
		},
		owner => root,
		group => root,
		mode  => 600,
		content => template("dpm/dpm-config.erb"),
	}
	file { 'dpm-sysconfig':
		name => $operatingsystem ? {
			default => '/etc/sysconfig/dpm',
		},
		owner => root,
		group => root,
		mode  => 644,
		content => template("dpm/dpm-sysconfig.erb"),
	}
}

class dpm::dpns {
	package { ['DPM-name-server-mysql']: ensure => latest }
	service { 'dpns':
		enable => true,
		ensure => running,
		hasrestart => true,
		hasstatus => true,
		name => 'dpnsdaemon',
		subscribe => File['dpns-config', 'dpns-sysconfig'],
	}
	file { 'dpns-config':
		name => $operatingsytem ? {
			default => '/opt/lcg/etc/NSCONFIG',
		},
		owner => dpmmgr,
		group => root,
		mode  => 600,
		content => template("dpm/dpns-config.erb"),
		recurse => inf,
	}
	file { 'dpns-sysconfig':
		name => $operatingsystem ? {
			default => '/etc/sysconfig/dpnsdaemon',
		},
		owner => root,
		group => root,
		mode  => 644,
		content => template("dpm/dpns-sysconfig.erb"),
	}
}

class dpm::client {
	package { 'dpm': ensure => latest }
}
