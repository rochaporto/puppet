# Defines a new VO in the setup (as seen by the VOMS service).
#
# == Parameters
#
# [*name*]
#   The name of the VO
#
# == Example
#
# Simply invoke the definition with the name of the VO to enable:
#   voms::vo { "MyVO": }
#
# Note that this will simply setup the voms environment, you need to
# additionally call the voms::server definition to configure the VOMS server.
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
define voms::vo {
  file { "vomsdir_$name":
    ensure  => directory,
    path    => "/etc/grid-security/vomsdir/$name",
    owner   => root,
    group   => root,
    mode    => 644,
    require => File["vomsdir"],
  }
}
