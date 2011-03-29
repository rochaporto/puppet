# Class defining resources for the CERN/IT/DMS build machinery.
#
# Prepares a machine for common build activities, like building RPMS.
# 
# == Parameters
#
# [*build_user*]
#   The username to use for build activities
#
# == Examples
#
# All you need is to include the class:
#   include dms::unstable
# 
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dms::build {
    $build_user = "builder"

    package { ["rpm-build", "yum-utils"]: ensure => latest, }

    user { "$build_user":
        ensure     => present,
        comment    => "dms build user",
        managehome => true,
    }
    
    file { ["/home/$build_user/rpm", "/home/$build_user/rpm/BUILD", "/home/$build_user/rpm/RPMS", 
            "/home/$build_user/rpm/SOURCES", "/home/$build_user/rpm/SPECS", "/home/$build_user/rpm/SRPMS"]:
        owner   => $build_user,
        ensure  => directory,
        require => User["$build_user"],
    }

    file { "/home/$build_user/.rpmmacros":
        ensure  => present,
        owner   => $build_user,
        content => template("dms/rpmmacros"),
        require => User["$build_user"],
    }
}
