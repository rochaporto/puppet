# site.pp

file { "/etc/sudoers":
	owner => root, group => root, mode => 440
}
