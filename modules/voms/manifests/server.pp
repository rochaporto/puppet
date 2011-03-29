# Defines a new VOMS server in the setup, for a particular VO.
#
# == Parameters
#
# [*vo*]
#   The name of the VO
#
# [*server*]
#   The address (dns) of the server machine
#
# [*port*]
#   The port where the VOMS service is listening
#
# [*dn*]
#   The distinguished name (DN) of the VOMS server machine
#
# [*ca_dn*]
#   The distinguished name (DN) of the certificate authority (CA) issuing
#   the VOMS server DN
#
# == Example
#
# Simply invoke the definition with the name of the VO to enable:
#   voms::server { 
#    "voms_MyVO_cern":
#      vo     => "MyVO",
#      server => "voms.cern.ch",
#      port   => 15001,
#      dn     => ["/DC=ch/DC=cern/OU=computers/CN=voms.cern.ch"],
#      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
#
# Do not forget to also invoke the voms::vo definition to properly setup the
# required local resources for that VO.
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
define voms::server($vo, $server, $port, $dn, $ca_dn) {
  file { 
    "voms_lsc_$vo-$server":
      path    => "/etc/grid-security/vomsdir/$vo/$server.lsc",
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("voms/lsc.erb"),
      require => File["vomsdir"];      
    "vomses_$vo-$server":
      path    => "/opt/glite/etc/vomses/$vo-$server",
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("voms/vomses.erb"),
      require => File["vomses"];
  }
}
