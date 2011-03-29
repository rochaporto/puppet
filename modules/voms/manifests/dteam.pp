# Class defining the DTEAM VO, as seen by the VOMS service.
#
# Takes care of all the required setup to enable access to the DTEAM VO
# (users and services) in a grid enabled machine.
#
# == Examples
# 
# Simply include this class:
#   include voms::dteam
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dteam {
  include voms

  voms::vo { "dteam": }

  voms::server {
    "voms_dteam_cern":
      vo     => "dteam",
      server => "voms.cern.ch",
      port   => 15001,
      dn     => ["/DC=ch/DC=cern/OU=computers/CN=voms.cern.ch"],
      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
    "voms_dteam_greece":
      vo     => "dteam",
      server => "voms.hellasgrid.gr",
      port   => 15001,
      dn     => ["/C=GR/O=HellasGrid/OU=hellasgrid.gr/CN=voms.hellasgrid.gr"],
      ca_dn  => ["/C=GR/O=HellasGrid/OU=Certification Authorities/CN=HellasGrid CA 2006"];
    "voms_dteam_greece2":
      vo     => "dteam",
      server => "voms2.hellasgrid.gr",
      port   => 15001,
      dn     => ["/C=GR/O=HellasGrid/OU=hellasgrid.gr/CN=voms2.hellasgrid.gr"],
      ca_dn  => ["/C=GR/O=HellasGrid/OU=Certification Authorities/CN=HellasGrid CA 2006"];
    "voms_dteam_lcg":
      vo     => "dteam",
      server => "lcg-voms.cern.ch",
      port   => 15001,
      dn     => ["/DC=ch/DC=cern/OU=computers/CN=lcg-voms.cern.ch"],
      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
    "voms_dteam_tbed":
      vo     => "dteam",
      server => "lxbra2309.cern.ch",
      port   => 15002,
      dn     => ["/DC=ch/DC=cern/OU=computers/CN=lxbra2309.cern.ch"],
      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
  }
}

