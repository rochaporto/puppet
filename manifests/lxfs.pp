# lxfs.pp

node lxfsbase {

    include dms::cbuilds::repo
    include dms::emi2::repos

    # dmlite adapter
    class{
      "dmlite::plugins::adapter::config":
        dpm_host 		=> "lxfsra04a04.cern.ch",
        connection_timeout 	=> 10,
        token_password 		=> "test",
        token_id	 	=> "ip",
	enable_rfio		=> true,
	enable_io		=> false,
    }
    class{"dmlite::plugins::adapter::install":}

    # gridftp configuration
    package{"dpm-dsi": ensure => latest}
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
        log_module		=> "stdio:buffer=0",
	login_msg		=> "Disk Pool Manager (dmlite)",
	port			=> 2811,
	thread_model		=> "pthread",

    }
    class{"gridftp::install":}
    class{"gridftp::service":}
}

node "lxfsra04a04.cern.ch" inherits lxfsbase {

    # dmlite s3
    class{"dmlite::plugins::s3::config":}
    class{"dmlite::plugins::s3::install":}

}

node "lxfsra12a06.cern.ch" inherits lxfsbase {


}
