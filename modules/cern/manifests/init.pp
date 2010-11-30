# Class: cern
#
# This class provides definitions and classes related to CERN specific instalations
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample usage:
#
class cern {
    
    class base {

        class afs {
            package { ["openafs", "openafs-client", "openafs-krb5", "useraddcern"]: 
                require => Yumrepo["slc5-updates"], 
            }
    
            file { "afs_sysconfig":
                name  => "/etc/sysconfig/afs",
                owner => "root",
                group => "root",
                mode  => 755,
            }

            file { "krb5_config":
                name  => "/etc/krb5.conf",
                owner => "root",
                group => "root",
                mode  => 644,
                content => template("cern/krb5.conf"),
            }
    
            service { "afs":
                enable     => true,
                ensure     => running,
                hasrestart => true,
                subscribe  => File["afs_sysconfig", "krb5_config"],
                require    => [
                    Package["openafs", "openafs-client", "openafs-krb5"], 
                    File["afs_sysconfig", "krb5_config"],
                ]
            }

            define user {
                exec { "afsuser_$name":
                    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                    command => "useraddcern $name",
                    unless  => "grep $name /etc/passwd",
                    require => Package["useraddcern"],
                }
            }
        }

        class hostcert {
            package { 
                "host-certificate-manager":
                    source => "http://swrepsrv.cern.ch/swrep/x86_64_slc5/host-certificate-manager-2.8-0.noarch.rpm",
                    provider => "rpm",
                    require  => Package["SINDES-tools"];
                "SINDES-tools":
                    source => "http://swrepsrv.cern.ch/swrep/x86_64_slc5/SINDES-tools-0.5-3.noarch.rpm",
                    provider => "rpm";
            }

            file {
                "/etc/grid-security":
                    mode => 755;
                "/etc/grid-security/hostcert.pem":
                    mode => 644,
                    require => [ File["/etc/grid-security"], Exec["hostcert_putcert"] ];
                "/etc/grid-security/hostkey.pem":
                    mode => 400,
                    require => [ Exec["hostcert_putcert"] ];
            }

            exec { 
                "hostcert_tmpclean":
                    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                    command => "rm -f /tmp/*/\$HOSTNAME/*host*pem",
                    refreshonly => true;
                "hostcert_get":
                    path        => "/usr/bin:/usr/sbin:/bin:/sbin",
                    environment => "HCMPASS=$cern_hcm_pass",
                    command     => "echo \$HCMPASS | host-certificate-manager --username gdadmin --nosindes `hostname -s`",
                    require     => Package["host-certificate-manager"],
                    refreshonly => true;
                "hostcert_putcert":
                    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                    command => "cp /tmp/*/\$HOSTNAME/host*.pem /etc/grid-security",
                    creates => ["/etc/grid-security/hostcert.pem", "/etc/grid-security/hostkey.pem"],
                    require => [ File["/etc/grid-security"], Exec["hostcert_get"] ],
                    notify  => Exec["hostcert_tmpclean"];
            }
        }
    }

    class slc5 inherits base {

        class repos {
            yumrepo { 
                "slc5-os":
                    descr    => "Scientific Linux CERN 5 (SLC5) base system packages",
                    baseurl  => "http://linuxsoft.cern.ch/cern/slc5X/\$basearch/yum/os/",
                    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpolok\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-csieh\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-dawson",
                    gpgcheck => 1,
                    enabled  => 1,
                    protect  => 1;
                "slc5-cernonly":
                    descr    => "Scientific Linux CERN 5 (SLC5) CERN-only packages",
                    baseurl  => "http://linuxsoft.cern.ch/onlycern/slc5X/\$basearch/yum/cernonly/",
                    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpolok",
                    gpgcheck => 1,
                    enabled  => 0,
                    protect  => 1;
                "slc5-updates":
                    descr    => "Scientific Linux CERN 5 (SLC5) bugfix and security updates",
                    baseurl  => "http://linuxsoft.cern.ch/cern/slc5X/\$basearch/yum/updates/",
                    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpolok\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-csieh\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-dawson",
                    gpgcheck => 1,
                    enabled  => 1,
                    protect  => 1;
                "slc5-extras":
                    descr    => "Scientific Linux CERN 5 (SLC5) add-on packages, no formal support",
                    baseurl  => "http://linuxsoft.cern.ch/cern/slc5X/\$basearch/yum/extras/",
                    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpolok",
                    gpgcheck => 1,
                    enabled  => 1,
                    protect  => 1;
                "sl5-security":
                    descr    => "SL 5 security updates",
                    baseurl  => "http://linuxsoft.cern.ch/scientific/5x/\$basearch/updates/security",
                    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-sl\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-sl5\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-csieh\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-dawson\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpolok\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-cern\n\tfile:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5",
                    gpgcheck => 1,
                    enabled  => 1;
                "swrep":
                    descr    => "CERN SWrep",
                    baseurl  => "http://swrepsrv.cern.ch/yum/CERN_CC/x86_64_slc5/",
                    gpgcheck => 0,
                    enabled  => 0;
            }
        }
    }

}
