# Class defining a DPM service.
#
# This is a reusable class for the different DPM daemons, taking care of all
# the common setup (user, group, common config files, etc).
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::service {
  include glite
  include dpm::lcgdmmap
  include dpm::shift

  package { 
    "vdt_globus_essentials": 
      ensure => latest, 
      notify => Exec["glite_ldconfig"]
  }
  
  group { "dpmmgr":
    ensure => present,
    gid    => 151, 
  }

  user { "dpmmgr": 
    ensure  => present,
    comment => "dpm manager", 
    uid     => 151, 
    gid     => "dpmmgr", 
    require => Group["dpmmgr"],
  }

  file { 
    "/etc/shift.conf":
      ensure => present,
      owner  => root,
      group  => root,
      mode   => 644;
    "/etc/grid-security/dpmmgr":
      ensure => directory,
      owner  => dpmmgr,
      group  => dpmmgr,
      mode   => 755,
      require => [
          File["/etc/grid-security"], User["dpmmgr"],
      ];
    "/etc/grid-security/dpmmgr/dpmcert.pem":
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 644,
      source  => "/etc/grid-security/hostcert.pem",
      require => [ 
          File["/etc/grid-security/hostcert.pem"], File["/etc/grid-security/dpmmgr"], User["dpmmgr"] 
      ];
    "/etc/grid-security/dpmmgr/dpmkey.pem":
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 400,
      source  => "/etc/grid-security/hostkey.pem",
      require => [ 
          File["/etc/grid-security/hostkey.pem"], File["/etc/grid-security/dpmmgr"], User["dpmmgr"] 
      ];
    "/opt":
      ensure  => directory,
      owner   => root,
      group   => root;
    "/opt/lcg":
      ensure  => directory,
      owner   => root,
      group   => root,
      require => File["/opt"];
    "/opt/lcg/etc":
      ensure  => directory,
      owner   => root,
      group   => root,
      require => File["/opt/lcg"];
    "/opt/lcg/etc/lcgdm-mapfile":
      ensure  => present,
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 600,
      require => [
          File["/opt/lcg/etc"], User["dpmmgr"]
      ];
    "/usr/share/augeas/lenses/dist/shift.aug":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 744,
      content => template("dpm/shift.aug");
    "/etc/sysconfig/iptables": # TODO: temporary fix, we should set iptables properly
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 600,
      content => template("dpm/iptables.erb"),
      notify  => Service["iptables"];
  }

  service { "iptables":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    name       => "iptables",
    subscribe  => File["/etc/sysconfig/iptables"],
  }
}
