# Class defining the DPM nameserver.
#
# This corresponding to the daemon responsible for handling all the namespace
# related requests.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::nameserver {
  include dpm::service
  include mysql::server

  package { "DPM-name-server-mysql":
    ensure  => latest, 
    notify  => Exec["glite_ldconfig"], 
    require => Package["lcg-CA"],
  }

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
    "dpns-logdir":
      name    => "/var/log/dpns",
      ensure  => directory,
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 755;
    "dpns-logfile":
      name    => $operatingsystem ? {
        default => $dpm_ns_logfile,
      },
      ensure  => present,
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 644,
      recurse => true,
      require => File["dpns-logdir"];
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

  dpm::shift::trust_entry { "trustentry_dpns": component => "DPNS", }
  dpm::shift::trust_value {
    "trustvalue_dpns_$dpm_ns_host": 
      component => "DPNS", host => $dpm_ns_host,
      require => Dpm::Shift::Trust_entry["trustentry_dpns"];
  }

  service { "dpns":
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    name       => "dpnsdaemon",
    subscribe  => File["dpns-config", "dpns-sysconfig"],
    require    => [ 
      Package["DPM-name-server-mysql"], File["dpns-config"], File["dpns-sysconfig"], 
      File["dpns-logfile"], Mysql::Server::Grant["cns_db_$dpm_ns_dbuser"], 
      Mysql::Server::Db["cns_db"], File["/etc/grid-security/dpmmgr/dpmcert.pem"],
      File["/etc/grid-security/dpmmgr/dpmcert.pem"],
      Dpm::Shift::Trust_value["trustvalue_dpns_$dpm_ns_host"],
    ],
  }
}
