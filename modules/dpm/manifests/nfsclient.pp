# Class defining a DPM client capable of talking NFS 4.1.
#
# Includes all the required packages (pNFS enabled client, nfs-utils), and
# also the automount configuration to mimic a global grid namespace.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::nfsclient {
  include dpm::client
  include glite::nfsclient

  package { "autofs": ensure => latest, }

  file {
    "/usr/share/augeas/lenses/dist/autofs.aug":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 744,
      content => template("dpm/autofs.aug");
    "/etc/auto.master":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 644;
    "/etc/auto.dpm":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("dpm/auto.dpm"),
      require => Augeas["automaster_augeas"];
    "/dpm":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => 644;
  }

  service { "autofs":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File["/etc/auto.master"],
    require    => [ Package["autofs"] ],
  }

  augeas { "automaster_augeas":
    changes => [
      "set /files/etc/auto.master/00/mnt /dpm",
      "set /files/etc/auto.master/00/config /etc/auto.dpm",
    ],
    onlyif  => "match /files/etc/auto.master/*[mnt = '/dpm' and config = '/etc/auto.dpm'] size == 0",
    require => [
      File["/usr/share/augeas/lenses/dist/autofs.aug"],
      File["/dpm"],
    ],
    notify  => Service["autofs"],
  }
}
