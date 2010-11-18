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
    }

    exec { "glite_ldconfig":
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
        command => "ldconfig",
        subscribe => [ File["glite_ldconf"], File["globus_ldconf"] ],
        refreshonly => true,
    }

}
