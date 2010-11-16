class glite {

  file { 'glite_ldconf':
	path => '/etc/ld.so.conf.d/glite.conf',
	owner => root,
	group => root,
	mode => 644,
	content => '/opt/glite/lib64',	
  }

  file { 'globus_ldconf':
	path => '/etc/ld.so.conf.d/globus.conf',
	owner => root,
	group => root,
	mode => 644,
	content => '/opt/globus/lib',	
  }

}
