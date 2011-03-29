# Class defining the ATLAS VO, as seen by the VOMS service.
#
# Takes care of all the required setup to enable access to the ATLAS VO
# (users and services) in a grid enabled machine.
#
# == Examples
# 
# Simply include this class:
#   include voms::atlas
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class voms::atlas {
  include voms

  voms::vo { "atlas": }

  voms::server { 
    "voms_atlas_cern":
      vo     => "atlas",
      server => "voms.cern.ch",
      port   => 15001,
      dn     => ["/DC=ch/DC=cern/OU=computers/CN=voms.cern.ch"],
      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
    "voms_atlas_lcg":
      vo     => "atlas",
      server => "lcg-voms.cern.ch",
      port   => 15001,
      dn     => ["/DC=ch/DC=cern/OU=computers/CN=lcg-voms.cern.ch"],
      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
  }
}

