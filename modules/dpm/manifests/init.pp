#
# dpm/init.pp
#
import 'glite'
import 'mysql'

#
# Class: dpm
#
# This class manages DPM nodes.
#
# Parameters:
#
#   - Cluster configuration
#   $dpm_ns_host 	= <hostname of machine running the DPM nameserver> : e.g 'dpns.cern.ch'
#   $dpm_host 		= <hostname of machine running the DPM service>    : e.g 'dpm.cern.ch'
#
#   - Nameserver configuration
#   $dpm_ns_dbuser 	= <database user name> : e.g. 'dpmmgr' 
#   $dpm_ns_dbpass 	= <database password>  : e.g. 'mypassword'
#   $dpm_ns_dbhost 	= <database hostname>  : e.g. 'localhost'
#   $dpm_ns_run 	= <should the nameserver run?> : default 'yes'
#   $dpm_ns_readonly 	= <run nameserver read only>   : default 'no'
#   $dpm_ns_ulimit 	= <limit for file descriptors> : default 4096 
#   $dpm_ns_coredump 	= <allow core dump>            : default 'yes'
#   $dpm_ns_configfile	= <db config file>             : default '/opt/lcg/etc/NSCONFIG'
#   $dpm_ns_logfile 	= <log file>                   : default '/var/log/dpns/log'
#   $dpm_ns_numthreads 	= <number of threads>          : default 20 
# 
#   - DPM server configuration
#   $dpm_dbuser 	= <database user name> : e.g. 'dpmmgr' 
#   $dpm_dbpass 	= <database password>  : e.g. 'mypassword'
#   $dpm_dbhost 	= <database hostname>  : e.g. 'localhost'
#   $dpm_run 		= <should the dpm server run?> : default 'yes'
#   $dpm_ulimit 	= <limit for file descriptors> : default 4096 
#   $dpm_coredump 	= <allow core dump>            : default 'yes'
#   $dpm_configfile	= <db config file>             : default '/opt/lcg/etc/NSCONFIG'
#   $dpm_logfile 	= <log file>                   : default '/var/log/dpns/log'
#   $dpm_gridmapdir     = <gridmap directory>          : default '/etc/grid-security/gridmapdir'
#
#   - SRM server configuration
#   $dpm_srm_run 		= <should the srm server run?> : default 'yes'
#   $dpm_srm_ulimit 		= <limit for file descriptors> : default 4096 
#   $dpm_srm_coredump 		= <allow core dump>            : default 'yes'
#   $dpm_srm_logfile 		= <log file>                   : default '/var/log/dpns/log'
#   $dpm_srm_gridmapdir     	= <gridmap directory>          : default '/etc/grid-security/gridmapdir'
#   $dpm_srm_gridmapfile    	= <gridmap file>               : default '/etc/grid-security/grid-mapfile'
#
#   - RFIO server configuration
#   $dpm_rfio_run 		= <should the rfio server run?> : default 'yes'
#   $dpm_rfio_ulimit 		= <limit for file descriptors>  : default 4096 
#   $dpm_rfio_logfile 		= <log file>                    : default '/var/log/dpns/log'
#   $dpm_rfio_portrange 	= <range of ports to listen>    : default '20000 25000'
#   $dpm_rfio_gridmapdir    	= <gridmap directory>           : default '/etc/grid-security/gridmapdir'
#   $dpm_rfio_options       	= <rfio daemon options>         : default '-sl'
#
#   - GSIFTP server configuration
#   $dpm_gsiftp_run 		= <should the gsiftp server run?> : default 'yes'
#   $dpm_gsiftp_logfile 	= <log file>                    : default '/var/log/dpm-gsiftp/dpm-gsiftp.log'
#   $dpm_gsiftp_portrange 	= <range of ports to listen>    : default '20000 25000'
#   $dpm_gsiftp_options       	= <gsiftp daemon options>       : default '-S -d all -p 2811 -auth-level 0 -dsi dpm -disable-usage-stats'
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dpm {

    class base {
        include glite
        
        package { ["vdt_globus_essentials"]: ensure => latest }

        group { "dpmmgr":
            gid    => 151, 
            ensure => present,
        }

        user { "dpmmgr": 
            comment => "dpm manager", 
            uid     => 151, 
            gid     => "dpmmgr", 
            ensure  => present,
            require => Group["dpmmgr"],
        }

        file { 
            "/etc/grid-security/dpmmgr":
                owner  => dpmmgr,
                group  => dpmmgr,
                mode   => 755,
                ensure => directory;
            "/etc/grid-security/dpmmgr/dpmcert.pem":
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 644,
                source  => "/etc/grid-security/hostcert.pem",
                require => File["/etc/grid-security/dpmmgr"];
            "/etc/grid-security/dpmmgr/dpmkey.pem":
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 400,
                source  => "/etc/grid-security/hostkey.pem",
                require => File["/etc/grid-security/dpmmgr"];
            "/opt/lcg/etc/lcgdm-mapfile":
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 600,
                ensure  => present,
                recurse => true;
        }
    }

    class dpm inherits base {
        include glite
        include mysql
        include mysql::server

        package { ["DPM-server-mysql"]:	ensure=> latest, }

        file {
            "dpm-config":
                path    => $operatingsytem ? {
                    default => $dpm_configfile,
                },
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 600,
                content => template("dpm/dpm-config.erb"),
                require => Package["DPM-server-mysql"];
            "dpm-sysconfig":
                name    => $operatingsystem ? {
                    default => '/etc/sysconfig/dpm',
                },
                owner   => root,
                group   => root,
                mode    => 644,
                content => template("dpm/dpm-sysconfig.erb");
            "dpm-logfile":
                name    => $operatingsystem ? {
                    default => $dpm_logfile,
                },
                ensure  => present,
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 644,
                recurse => true;
        }

        mysql::server::grant { "dpm_db_$dpm_dbuser":
            user     => $dpm_dbuser,
            password => $dpm_dbpass,
            db       => "dpm_db",
            require  => Mysql::Server::Db["dpm_db"],
        }

        mysql::server::db { "dpm_db":
            source => "/opt/lcg/share/DPM/create_dpm_tables_mysql.sql",
        }

        service { "dpm":
            enable    => true,
            ensure    => running,
            subscribe => File["dpm-config", "dpm-sysconfig"],
            require   => [ 
                Package["DPM-server-mysql"], File["dpm-config"], File["dpm-sysconfig"], 
                File["dpm-logfile"], Mysql::Server::Grant["dpm_db_$dpm_dbuser"], Mysql::Server::Db["dpm_db"] 
            ],
        }

    }

    class nameserver inherits base {
        include glite
        include mysql
        include mysql::server

        package { ["DPM-name-server-mysql"]: ensure=> latest, }

        file { 
            "dpns-config":
                name    => $operatingsytem ? {
                    default => $dpm_ns_configfile,
                },
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 600,
                content => template("dpm/dpns-config.erb"),
                require => Package["DPM-name-server-mysql"];
            "dpns-sysconfig":
                name    => $operatingsystem ? {
                    default => "/etc/sysconfig/dpnsdaemon",
                },
                owner   => root,
                group   => root,
                mode    => 644,
                content => template("dpm/dpns-sysconfig.erb");
            "dpns-logfile":
                name    => $operatingsystem ? {
                    default => $dpm_ns_logfile,
                },
                ensure  => present,
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 644,
                recurse => true;
        }

        mysql::server::grant { "cns_db_$dpm_ns_dbuser":
            user     => $dpm_ns_dbuser,
            password => $dpm_ns_dbpass,
            db       => "cns_db",
            require  => Mysql::Server::Db["cns_db"],
        }

        mysql::server::db { "cns_db":
            source => "/opt/lcg/share/DPM/create_dpns_tables_mysql.sql",
        }

        service { "dpns":
            enable    => true,
            ensure    => running,
            name      => "dpnsdaemon",
            subscribe => File["dpns-config", "dpns-sysconfig"],
            require   => [ 
                Package["DPM-name-server-mysql"], File["dpns-config"], File["dpns-sysconfig"], 
			    File["dpns-logfile"], Mysql::Server::Grant["cns_db_$dpm_ns_dbuser"], 
                Mysql::Server::Db["cns_db"] 
            ],
        }
    }
		

    class srm inherits base {
        include glite

        package { ["DPM-srm-server-mysql"]: ensure=> latest, }

        file { 
            "srm-sysconfig":
                name    => $operatingsystem ? {
                    default => '/etc/sysconfig/srmv2.2',
                },
                owner   => root,
                group   => root,
                mode    => 644,
                content => template("dpm/srm-sysconfig.erb");
            "srm-logdir": # required to fix missing dir in the srmv2.2 rpm
                name   => "/var/log/srmv2.2",
                owner  => dpmmgr,
                group  => dpmmgr,
                mode   => 644,
                ensure => directory;
            "srm-logfile":
                name    => $operatingsystem ? {
                    default => $dpm_srm_logfile,
                },
                ensure  => present,
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 644,
                recurse => true;
        }

        service { "srm":
            enable    => true,
            ensure    => running,
            name      => "srmv2.2",
            subscribe => File["srm-sysconfig"],
            require   => [ 
                Service["dpm"], Service["dpns"], Package["DPM-srm-server-mysql"], 
                File["srm-sysconfig"], File["srm-logdir"], File["srm-logfile"]
            ],
        }
    }

    class gridftp inherits base {
  	    include glite
	
        # TODO: dpm-devel only need due to missing dep in DPM-DSI
        package { ["DPM-DSI", "vdt_globus_data_server", "dpm-devel"]: ensure=> latest, }

        file { 
            "dpm-gsiftp-sysconfig":
                name    => $operatingsystem ? {
                    default => "/etc/sysconfig/dpm-gsiftp",
                },
                owner   => root,
                group   => root,
                mode    => 644,
                content => template("dpm/dpm-gsiftp-sysconfig.erb");
            "dpm-gsiftp-logdir": # required to fix missing dir in the rfio rpm
                name   => "/var/log/dpm-gsiftp",
                owner  => root,
                group  => root,
                mode   => 644,
                ensure => directory;
            "dpm-gsiftp-logfile":
                name    => $operatingsystem ? {
                    default => $dpm_gsiftp_logfile,
                },
                ensure  => present,
                owner   => root,
                group   => root,
                mode    => 666,
                recurse => true;
        }

        service { "dpm-gsiftp":
            enable    => true,
            ensure    => running,
            subscribe => File["dpm-gsiftp-sysconfig"],
            require   => [ 
                Package["DPM-DSI"], File["dpm-gsiftp-sysconfig"], File["dpm-gsiftp-logdir"], 
                File["dpm-gsiftp-logfile"] 
            ],
        }
    }

    class rfio inherits base {
        include glite

        package { ["DPM-rfio-server"]: ensure=> latest, }

        file { 
            "rfio-sysconfig":
                name    => $operatingsystem ? {
                    default => "/etc/sysconfig/rfiod",
                },
                owner   => root,
                group   => root,
                mode    => 644,
                content => template("dpm/rfio-sysconfig.erb");
            "rfio-logdir": # required to fix missing dir in the rfio rpm
                name   => "/var/log/rfio",
                owner  => root,
                group  => root,
                mode   => 644,
                ensure => directory;
            "rfio-logfile":
                name    => $operatingsystem ? {
                    default => $dpm_rfio_logfile,
                },
                ensure  => present,
                owner   => dpmmgr,
                group   => dpmmgr,
                mode    => 666,
                recurse => true;
        }

        service { "rfiod":
            enable    => true,
            ensure    => running,
            subscribe => File["rfio-sysconfig"],
            require   => [ 
                Package["DPM-rfio-server"], File["rfio-sysconfig"], File["rfio-logdir"], File["rfio-logfile"] 
            ],
        }
    }

    class client {
        package { "dpm": ensure => latest }
    }

    class headnode {
        include nameserver
        include dpm
        include srm
        include client

        file { "headnode-shiftconf":
            path    => "/etc/shift.conf",
            owner   => root,
            group   => root,
            mode    => 644,
            content => template("dpm/headnode-shift.erb"),
        }

        define domain {
            exec { "dpm_domain_$dpm_ns_host-$name":
                path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
                environment => "DPNS_HOST=$dpm_ns_host",
                command     => "dpns-mkdir -p /dpm/$name",
                unless      => "dpns-ls /dpm/$name",
                require     => Package["dpm"],
            }
        }

        define vo($domain) {
            $vo_path = "/dpm/$domain/home/$name"
            exec { "dpm_vo_$dpm_ns_host-$domain-$name":
                path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
                environment => "DPNS_HOST=$dpm_ns_host",
                command     => "dpns-mkdir -p $vo_path; dpns-chmod 755 $vo_path; dpns-entergrpmap --group $name; dpns-chown root:$name $vo_path; dpns-setacl -m d:u::7,d:g::7,d:o:5 $vo_path",
                unless      => "dpns-ls /dpm/$domain/home/$name",
                require     => Package["dpm"],
            }
        }

        define pool {
            exec { "dpm_pool_$dpm_host-$name":
                path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
                environment => "DPM_HOST=$dpm_host",
                command     => "dpm-addpool --poolname $name",
                unless      => "dpm-qryconf | grep 'POOL $name '",
                require     => Package["dpm"],
            }
        }
    }

    class disknode {
        include gridftp
        include rfio
        include client

        file { "disknode-shiftconf":
            path    => "/etc/shift.conf",
            owner   => root,
            group   => root,
            mode    => 644,
            content => template("dpm/disknode-shift.erb"),
        }

        define loopback($blocks, $bs="1M", $type="ext3") {
            $file = "$name-partition-file"
            exec { "dpm_loopback_$fqdn-$name":
                path    => "/usr/bin:/usr/sbin:/bin",
                command => "mkdir -p $name; dd if=/dev/zero of=$file bs=$bs count=$blocks; mkfs.$type -F $file",
                unless  => "ls -l $name",
            }
        }

        define filesystem($pool) {
            exec { "dpm_filesystem_$fqdn-$name":
                path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
                environment => "DPM_HOST=$dpm_host",
                command     => "dpm-addfs --poolname $pool --server $fqdn --fs $name",
                unless      => "dpm-qryconf | grep '  $fqdn $name '",
                require     => Package["dpm"],
            }
        }
    }

}
