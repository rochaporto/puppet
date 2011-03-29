# Class defining a VOMS client, install all required packages.
#
# == Examples
# 
# Simply include this class:
#   include voms::client
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class voms::client {

  package { "glite-security-voms-clients": 
    ensure  => latest, 
    notify  => Exec["glite_ldconfig"],
    require => Package["lcg-CA"],
  }

}
