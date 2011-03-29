# Class defining the DPM server (stager).
#
# This corresponding to the daemon responsible for handling the storage resource
# management - space assignement, replica management, ...
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::dpmserver {
  include dpm::service
  include mysql::server

  package { "DPM-server-mysql":
      ensure  => latest, 
      notify  => Exec["glite_ldconfig"],
      require => Package["lcg-CA"],
  }

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
    "dpm-logdir":
      ensure  => directory,
      name    => "/var/log/dpm",
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 755;
    "dpm-logfile":
      ensure  => present,
      name    => $operatingsystem ? {
        default => $dpm_logfile,
      },
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 644,
      recurse => true,
      require => File["dpm-logdir"];
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

  dpm::shift::trust_entry { "trustentry_dpm": component => "DPM", }
  dpm::shift::trust_value {
    "trustvalue_dpm_$dpm_host": 
      component => "DPM", host => $dpm_host,
      require => Dpm::Shift::Trust_entry["trustentry_dpm"];
  }

  service { "dpm":
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    name       => "dpm",
    subscribe  => File["dpm-config", "dpm-sysconfig"],
    require    => [ 
      Package["DPM-server-mysql"], File["dpm-config"], File["dpm-sysconfig"], 
      File["dpm-logfile"], Mysql::Server::Grant["dpm_db_$dpm_dbuser"], Mysql::Server::Db["dpm_db"],
      File["/etc/grid-security/dpmmgr/dpmcert.pem"],
      Dpm::Shift::Trust_value["trustvalue_dpm_$dpm_host"],
    ],
  }

}
