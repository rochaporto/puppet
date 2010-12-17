# Class: voms
# 
# This class provides definitions to manage a VOMS installation
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class voms {
    include glite

    class client {
        package { "glite-security-voms-clients": 
            ensure  => latest, 
            notify  => Exec["glite_ldconfig"],
            require => Package["lcg-CA"],
        }
    }

    class base {
        file { 
            "vomsdir":
                path   => "/etc/grid-security/vomsdir",
                owner  => root,
                group  => root,
                mode   => 644,
                ensure => directory,
                require => File["/etc/grid-security"];
            "vomses":
                path    => "/opt/glite/etc/vomses",
                owner   => root,
                group   => root,
                mode    => 755,
                ensure  => directory,
                require => File["glite_etc"],
        }

        define vo {
            file { "vomsdir_$name":
                path    => "/etc/grid-security/vomsdir/$name",
                owner   => root,
                group   => root,
                mode    => 644,
                ensure  => directory,
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

    class atlas {
        include voms::base

        voms::base::vo { "atlas": }

        voms::base::server { 
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

    class dteam {
        include voms::base

        voms::base::vo { "dteam": }

        voms::base::server {
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
}

