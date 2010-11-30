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

    package { "edg-mkgridmap": ensure => latest, }

    file { 
        "glite_ldconf":
            path => "/etc/ld.so.conf.d/glite.conf",
            owner => root,
            group => root,
            mode => 644,
            content => "/opt/glite/lib64";
        "globus_ldconf":
            path => "/etc/ld.so.conf.d/globus.conf",
            owner => root,
            group => root,
            mode => 644,
            content => "/opt/globus/lib";
        "glite_etc":
            path   => "/opt/glite/etc",
            owner  => root,
            group  => root,
            mode   => 755,
            ensure => directory;
        "/usr/share/augeas/lenses/dist/mkgridmap.aug":
            owner   => root,
            group   => root,
            mode    => 755,
            ensure  => present,
            content => template("glite/mkgridmap.aug");
    }

    exec { "glite_ldconfig":
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
        command => "ldconfig",
        subscribe => [ File["glite_ldconf"], File["globus_ldconf"] ],
        refreshonly => true,
    }

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
            command => "(date; /opt/edg/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe) >> $logfile 2>&1",
            environment => "PATH=/sbin:/bin:/usr/sbin:/usr/bin",
            user    => root,
            hour    => [5,11,18,23],
            minute  => 55,
            require => [
                File["$name-conf"],
                Package["edg-mkgridmap"],
            ],
        }

    }

    class gridmap {
        glite::mkgridmap { "edg-mkgridmap":
            conffile => "/opt/edg/etc/edg-mkgridmap.conf",
            mapfile  => "/etc/grid-security/grid-mapfile",
            logfile  => "/var/log/edg-mkgridmap.log",
        }
    }

}
