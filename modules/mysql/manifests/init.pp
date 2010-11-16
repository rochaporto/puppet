class mysql {

	class server {
		package { "mysql-server": ensure => latest }

		define grant($user, $password, $db, $host='localhost') {
			exec { "mysql_user_grant_$user_$db":
				path => "/usr/bin:/usr/sbin:/bin",
				command => "mysql -uroot -e \"grant all privileges on $db.* to '$user'@'$host' identified by '$password'\"",
				unless => "mysql -u$user -p$password -D$db -h$host",
			}
		}
	
		define db($source) {
			exec { "mysql_schema_load_$name":
				path => "/usr/bin:/usr/sbin:/bin",
				command => "mysql -uroot < $source",
				unless => "mysql -uroot -e \"use $name\"",
			}
		}

		service { "mysqld":
			enable => true,
			ensure => running,
			hasrestart => true,
			hasstatus => true,
		}
	}
}
