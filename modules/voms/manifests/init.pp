# Class defining resources required to use the VOMS service.
#
# == Examples
# 
# Simply include this class:
#   include voms
#
# And then enable one or more VOs by calling the 'vo' and 'server' definitions:
#   voms::vo { "MyVO": }
#
#   voms::server { 
#    "voms_MyVO_cern":
#      vo     => "MyVO",
#      server => "voms.cern.ch",
#      port   => 15001,
#      dn     => ["/DC=ch/DC=cern/OU=computers/CN=voms.cern.ch"],
#      ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class voms {

  file { 
    "vomsdir":
      ensure => directory,
      path   => "/etc/grid-security/vomsdir",
      owner  => root,
      group  => root,
      mode   => 644,
      require => File["/etc/grid-security"];
    "vomses":
      ensure  => directory,
      path    => "/opt/glite/etc/vomses",
      owner   => root,
      group   => root,
      mode    => 755,
      require => File["glite_etc"],
  }

  define vo {
    file { "vomsdir_$name":
      ensure  => directory,
      path    => "/etc/grid-security/vomsdir/$name",
      owner   => root,
      group   => root,
      mode    => 644,
      require => File["vomsdir"],
    }
  }

  define server($vo, $server, $port, $dn, $ca_dn) {
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
}
