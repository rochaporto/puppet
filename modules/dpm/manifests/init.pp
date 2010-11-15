# init.pp

group { 'dpmmgr': 
	gid => 151, 
	ensure => present,
}

user { 'dpmmgr': 
	comment => 'dpm manager', 
	uid => 151, 
	gid => 'dpmmgr', 
	ensure => present,
}

class dpm {

  class headnode {
	include nameserver
	include srm
  }

  class disknode {
	include gridftp
	include rfio
  }

  class dpm {

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

  class nameserver {

	package { ['DPM-name-server-mysql','vdt_globus_essentials']: ensure => latest }

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
			default => $dpm_ns_configfile,
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

	file {
		'dpns-logfile':
		name => $operatingsystem ? {
			default => $dpm_ns_logfile,
		},
		owner => dpmmgr,
		group => dpmmgr,
		mode  => 644,
	}

  }

  class srm {

  }

  class gridftp {

  }

  class rfio {

  }

  class client {

	package { 'dpm': ensure => latest }

  }

}
