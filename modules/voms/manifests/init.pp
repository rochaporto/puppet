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

    class client {
        package { "glite-security-voms-clients": ensure => latest, notify => Exec["glite_ldconfig"], }
    }

    class base {
        file { 
            "vomsdir":
                path   => "/etc/grid-security/vomsdir",
                owner  => root,
                group  => root,
                mode   => 644,
                ensure => directory;
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

        define group($file, $voms_uri, $vo) {
            augeas { "vomsgroup_$file-$voms_uri-$vo":
                changes => [
                    "set /files$file/01/type group",
                    "set /files$file/01/uri $voms_uri",
                    "set /files$file/01/vo $vo",
                ],
                onlyif => "match /files$file/*[type='group' and uri='$voms_uri' and vo='$vo'] size == 0",
                require => File[$file],
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

        voms::base::group { "voms_atlas_cern":
            file     => "/opt/edg/etc/edg-mkgridmap.conf",
            voms_uri => "vomss://voms.cern.ch:8443/voms/atlas?/atlas",
            vo       => "atlas",
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

        voms::base::group { 
            "voms_dteam_cern":
                file     => "/opt/edg/etc/edg-mkgridmap.conf",
                voms_uri => "vomss://voms.cern.ch:8443/voms/dteam?/dteam",
                vo       => "dteam";
            "voms_dteam_tbed":
                file     => "/opt/edg/etc/edg-mkgridmap.conf",
                voms_uri => "vomss://lxbra2309.cern.ch:8443/voms/dteam?/dteam",
                vo       => "dteam";
        }
    }
}

