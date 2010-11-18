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

    $vos = []
    $voms_groups = []

    file { "vomsdir":
        path   => "/etc/grid-security/vomsdir",
        owner  => root,
        group  => root,
        mode   => 644,
        ensure => directory,
    }

    define vo {
        $voms::vos += $name

        file { "vomsdir_$name":
            path   => "/etc/grid-security/vomsdir/$name",
            owner  => root,
            group  => root,
            mode   => 644,
            ensure => directory,
        }
    }

    define server($vo, $server, $port, $dn, $ca_dn) {
        file { "voms_lsc_$vo-$server":
            path    => "/etc/grid-security/vomsdir/$vo/$server.lsc",
            owner   => root,
            group   => root,
            mode    => 644,
            content => template("voms/lsc.erb"),
        }
    }

    define group {
        $voms::voms_groups += $name
	Notify<| tag == "gridmap" |>
    }

    class atlas {
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

        voms::group { ["vomss://voms.cern.ch:8443/voms/atlas?/atlas/ atlas"]: }
    }

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
            "voms_dteam_lcg":
                vo     => "dteam",
                server => "lcg-voms.cern.ch",
                port   => 15001,
                dn     => ["/DC=ch/DC=cern/OU=computers/CN=lcg-voms.cern.ch"],
                ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
            "voms_dteam_tbed":
                vo     => "dteam",
                server => "lxbra2309.cern.ch",
                port   => 15004,
                dn     => ["/DC=ch/DC=cern/OU=computers/CN=lxbra2309.cern.ch"],
                ca_dn  => ["/DC=ch/DC=cern/CN=CERN Trusted Certification Authority"];
        }

        voms::group { ["vomss://voms.cern.ch:8443/voms/dteam?/dteam/ dteam", "vomss://lxbra2309.cern.ch:8443/voms/dteam?/dteam dteam"]: }
    }
}

