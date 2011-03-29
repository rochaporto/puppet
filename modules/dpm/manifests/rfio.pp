# Class defining the DPM RFIO service.
#
# This corresponding to the daemon answering RFIO requests, and exposing
# POSIX like file access functionality (open, read, write, close, ...).
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::rfio  {
  include dpm::service

  package { ["DPM-rfio-server"]: ensure=> latest, notify => Exec["glite_ldconfig"], }

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
      ensure => directory,
      name   => "/var/log/rfio",
      owner  => root,
      group  => root,
      mode   => 644;
    "rfio-logfile":
      ensure  => present,
      name    => $operatingsystem ? {
        default => $dpm_rfio_logfile,
      },
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 666,
      recurse => true,
      require => File["rfio-logdir"];
  }

  dpm::shift::trust_entry { "trustentry_rfiod_all": component => "RFIOD", all => true, }
  dpm::shift::trust_value { 
    "trustvalue_rfiod_$dpm_host": 
      component => "RFIOD", host => $dpm_host, all => true, 
      require => Dpm::Shift::Trust_entry["trustentry_rfiod_all"];
  }

  service { "rfiod":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File["rfio-sysconfig"],
    require    => [
      Package["DPM-rfio-server"], File["rfio-sysconfig"], File["rfio-logdir"], 
      File["rfio-logfile"], Dpm::Shift::Trust_value["trustvalue_rfiod_$dpm_host"],
    ],
  }
}
