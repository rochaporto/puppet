# Class defining the DPM GridFTP service.
#
# This corresponding to the daemon answering GSI enabled FTP requests.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::gridftp {
  include dpm::service

  # TODO: dpm-devel only need due to missing dep in DPM-DSI
  package { ["DPM-DSI", "vdt_globus_data_server", "dpm-devel"]: 
    ensure=> latest,
    notify => Exec["glite_ldconfig"], 
  }

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
      ensure => directory,
      name   => "/var/log/dpm-gsiftp",
      owner  => root,
      group  => root,
      mode   => 644;
    "dpm-gsiftp-logfile":
      ensure  => present,
      name    => $operatingsystem ? {
          default => $dpm_gsiftp_logfile,
      },
      owner   => root,
      group   => root,
      mode    => 666,
      recurse => true,
      require => File["dpm-gsiftp-logdir"],
  }

  service { "dpm-gsiftp":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File["dpm-gsiftp-sysconfig"],
    require    => [ 
        Package["DPM-DSI"], Package["vdt_globus_data_server"], Package["dpm-devel"],
        File["dpm-gsiftp-sysconfig"], File["dpm-gsiftp-logdir"], File["dpm-gsiftp-logfile"] 
    ],
  }
}
