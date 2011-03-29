# Class defining the DPM SRM service.
#
# This corresponding to the daemon answering SRM requests, and exposing
# functionality to manage the storage resources remotely.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::srm {
  include dpm::service
  include mysql::server

  package { ["DPM-srm-server-mysql"]: ensure=> latest, notify => Exec["glite_ldconfig"], }

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
      recurse => true,
      require => File["srm-logdir"],
  }

  service { "srm":
    enable     => true,
    ensure     => running,
    name       => "srmv2.2",
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File["srm-sysconfig"],
    require    => [ 
      Service["dpm"], Service["dpns"], Package["DPM-srm-server-mysql"], 
      File["srm-sysconfig"], File["srm-logdir"], File["srm-logfile"],
    ],
  }
}
