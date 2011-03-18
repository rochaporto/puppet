import "cern"

# Class: dms
# 
# This class provides definitions and classes specific to the CERN IT/GT/DMS section
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dms {

    class unstable inherits cern::slc5 {
        include cern::slc5::repos

        package { "yum-protectbase": }

        package { "lcgdm-libs": require => Package["yum-protectbase"] }

        yumrepo { 
            "dpm-mysql-unstable-etics":
                descr    => "DPM MySQL ETICS Unstable Repository",
                baseurl  => "http://etics-repository.cern.ch/repository/pm/volatile/repomd/name/lcgdm_unstable_sl5_x86_64_gcc412",
                gpgcheck => 0,
                enabled  => 1,
                protect  => 1;
            "lcgutil-head-etics":
                descr    => "LCGUTIL ETICS Unstable Repository",
                baseurl  => "http://etics-repository.cern.ch/repository/pm/volatile/repomd/name/lcgutil_head_sl5_x86_64_gcc412",
                gpgcheck => 0,
                enabled  => 1,
                protect  => 1;
            "glite-global-etics":
                descr    => "ETICS Global gLite Registered Repository",
                baseurl  => "http://etics-repository.cern.ch/repository/pm/registered/repomd/global/org.glite/sl5_x86_64_gcc412",
                gpgcheck => 0,
                enabled  => 1,
                protect  => 0;
            "nfsv41":
                descr    => "Scientific Linux pNFS enabled kernel",
                baseurl  => "https://grid-deployment.web.cern.ch/grid-deployment/dms/yum/sl5/nfs41",
                gpgcheck => 0,
                enabled  => 1,
        }
    }

    class build {
        $build_user = "builder"

        package { ["rpm-build", "yum-utils"]: ensure => latest, }

        user { "$build_user":
            comment    => "dms build user",
            ensure     => present,
            managehome => true,
        }
        
        file { ["/home/$build_user/rpm", "/home/$build_user/rpm/BUILD", "/home/$build_user/rpm/RPMS", 
                "/home/$build_user/rpm/SOURCES", "/home/$build_user/rpm/SPECS", "/home/$build_user/rpm/SRPMS"]:
            owner   => $build_user,
            ensure  => directory,
            require => User["$build_user"],
        }

        file { "/home/$build_user/.rpmmacros":
            owner   => $build_user,
            ensure  => present,
            content => template("dms/rpmmacros"),
            require => User["$build_user"],
        }
    }
}
