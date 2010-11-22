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

        package { "yum-protectbase": }

        package { "lcgdm-libs": require => Package["yum-protectbase"] }

        yumrepo { "dpm-mysql-unstable-etics":
            descr    => "DPM MySQL ETICS Unstable Repository",
            baseurl  => "http://etics-repository.cern.ch/repository/pm/volatile/repomd/name/lcgdm_unstable_sl5_x86_64_gcc412",
            gpgcheck => 0,
            enabled  => 1,
            protect  => 1,
        }

        yumrepo { "epel":
            descr    => "Extra Packages for Enterprise Linux 5 - \$basearch",
            baseurl  => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=$basearch",
            gpgcheck => 0,
            enabled  => 1,
            protect  => 0,
        }

        yumrepo { "lcg-ca":
            descr    => "LCG Certificate Authorities (CAs)",
            baseurl  => "http://linuxsoft.cern.ch/LCG-CAs/current",
            gpgcheck => 0,
            enabled  => 1,
        }

    }

}
