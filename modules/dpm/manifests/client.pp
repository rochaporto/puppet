# Class defining a DPM client.
#
# It installs and manages all the required environment and configuration files.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::client  {
  include glite

  package { 
    "dpm": 
      ensure => latest, 
      notify => Exec["glite_ldconfig"];
  }

  file {
    "/etc/profile.d/dpm.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("dpm/dpm-profile.erb");
  }
}
