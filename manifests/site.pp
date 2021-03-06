# site.pp
import 'lxfs.pp'

node base {

    package {"lcg-CA": ensure => latest }

}

node "rocha-el6.cern.ch" inherits base {

    # dmlite configuration
    class{
      "dmlite::plugins::adapter::config":
        dpm_host 		=> "lxfsra04a04.cern.ch",
        connection_timeout 	=> 10,
	enable_rfio		=> true,
	enable_io		=> false,
	notify			=> Service["globus-gridftp-server"],
    }
    class{"dmlite::plugins::adapter::install":}

    # gridftp configuration
    file { 
	"/var/log/dpm-gsiftp": 
		ensure => directory 
    }
    class{"gridftp::config": 
	auth_level		=> 0,
	detach			=> 1,
	disable_usage_stats	=> 1,
	load_dsi_module 	=> "dmlite",
	log_single		=> "/var/log/dpm-gsiftp/gridftp.log",
	log_transfer		=> "/var/log/dpm-gsiftp/dpm-gsiftp.log",
	log_level		=> "ALL",
	login_msg		=> "Disk Pool Manager (dmlite)",
	port			=> 2811,
	thread_model		=> "pthread",

    }
    class{"gridftp::install":}
    class{"gridftp::service":}

    # webdav configuration
    apache::mod {"ssl": }
    class{"dmlite::apache::lcgdm_ns": }

}
