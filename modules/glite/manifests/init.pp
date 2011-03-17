# Class: glite
#
# This class provides definitions specific to the glite software stack
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class glite {

    package { ["edg-mkgridmap", "lcg-CA"]: ensure => latest, }

    file { 
        "/etc/profile.d/glite.sh":
            owner  => root,
            group  => root,
            mode   => 755,
            content => template("glite/glite.sh.erb"),
            ensure => present;
        "/etc/grid-security":
            owner  => root,
            group  => root,
            mode   => 755,
            ensure => directory;
        "glite_ldconf":
            path    => "/etc/ld.so.conf.d/glite.conf",
            owner   => root,
            group   => root,
            mode    => 644,
            content => "/opt/glite/lib64";
        "globus_ldconf":
            path    => "/etc/ld.so.conf.d/globus.conf",
            owner   => root,
            group   => root,
            mode    => 644,
            content => "/opt/globus/lib";
        "glite":
            path   => "/opt/glite",
            owner  => root,
            group  => root,
            mode   => 755,
            ensure => directory;
        "glite_etc":
            path    => "/opt/glite/etc",
            owner   => root,
            group   => root,
            mode    => 755,
            ensure  => directory,
            require => File["glite"];
        "edg":
            path   => "/opt/edg",
            owner  => root,
            group  => root,
            mode   => 755,
            ensure => directory;
        "edg_etc":
            path    => "/opt/edg/etc",
            owner   => root,
            group   => root,
            mode    => 755,
            ensure  => directory,
            require => File["edg"];
        "/usr/share/augeas/lenses/dist/mkgridmap.aug":
            owner   => root,
            group   => root,
            mode    => 755,
            ensure  => present,
            content => template("glite/mkgridmap.aug");
    }

    exec { "glite_ldconfig":
        path        => "/usr/bin:/usr/sbin:/bin:/sbin",
        command     => "ldconfig",
        subscribe   => [ File["glite_ldconf"], File["globus_ldconf"] ],
        refreshonly => true,
    }

    class gridmap {

        define mkgridmap($conffile, $mapfile, $logfile) {
            file { "$name-conf":
                path    => $conffile,
                owner   => root,
                group   => root,
                mode    => 644,
                tag     => "gridmap",
                ensure  => present,
            }

            cron { "$name-cron":
                command     => "(date; /opt/edg/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe) >> $logfile 2>&1",
                environment => "PATH=/sbin:/bin:/usr/sbin:/usr/bin",
                user        => root,
                hour        => [5,11,18,23],
                minute      => 55,
                require     => [
                    File["$name-conf"],
                    Package["edg-mkgridmap"],
                ],
            }

            exec { "$conffile-exec":
                path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
                command     => "/opt/edg/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe",
                refreshonly => true,
            }
        }

        #
        # Manages entries in a mkgridmap config file. 
        # 
        # mkgridmap files provide the configuration of the edg-mkgridmap script, which
        # generates mapfiles by contacting the given VOMS URI, listing the users, and setting
        # a local mapping to the given 'map' value.
        #
        # Can be used for both pool account and VO mapping of DNs.
        #
        # $file:     The location of the mkgridmap config file to add the info to
        # $voms_uri: The URI of the VOMS server to be used when generating the mapfile
        # $map:      The value to map the DNs to
        #
        define group($file, $voms_uri, $map) {
            augeas { "vomsgroupadd_$file-$voms_uri-$map":
                changes => [
                    "set /files$file/01/type group",
                    "set /files$file/01/uri $voms_uri",
                    "set /files$file/01/map $map",
                ],
                onlyif => "match /files$file/*[type='group' and uri='$voms_uri'] size == 0",
                require => File[$file],
                notify  => Exec["$file-exec"],
            }
            augeas { "vomsgroupupdate_$file-$voms_uri-$map":
                changes => [
                    "set /files$file/*[type='group' and uri='$voms_uri']/map $map",
                ],
                onlyif => "match /files$file/*[type='group' and uri='$voms_uri' and map!='$map'] size > 0",
                require => File[$file],
                notify  => Exec["$file-exec"],
            }
        }
    
        glite::gridmap::mkgridmap { "edg-mkgridmap":
            conffile => "/opt/edg/etc/edg-mkgridmap.conf",
            mapfile  => "/etc/grid-security/grid-mapfile",
            logfile  => "/var/log/edg-mkgridmap.log",
            require  => [ File["edg_etc"], File["/etc/grid-security"] ],
        }
    }

    class nfs {
        class client {
            package { ["nfs-utils-lib"]: ensure => absent, }

            package { ["kernel-pnfs", "nfs-utils"]: ensure => latest, }
        }
    }
}
