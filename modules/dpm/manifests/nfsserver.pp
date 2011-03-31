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
class dpm::nfsserver {

  package { 
    "nfs-ganesha-common": 
      ensure => latest;
    "nfs-ganesha-dpm": 
      ensure  => latest,
      require => Package["nfs-ganesha-common"];
  }

  file {
    "conf-ganesha-dpm":
      name    => "/etc/ganesha/ganesha.conf",
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 0600,
      content => template("dpm/ganesha.conf.erb"),
      require => Package["nfs-ganesha-dpm"];
  }

  service { "nfs-ganesha-dpm":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    subscribe  => File["conf-ganesha-dpm"],
    require    => [ Package["nfs-ganesha-common", "nfs-ganesha-dpm"], File["conf-ganesha-dpm"], ],
    status     => "ps aux | grep ganesha", # TODO: remove this once the init script 'status' works
  }

}
