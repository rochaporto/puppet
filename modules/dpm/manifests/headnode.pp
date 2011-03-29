# Class defining a DPM Head Node.
#
# A DPM Head Node includes the following services: nameserver, dpm server,
# SRM and the required clients.
#
# This is only useful if you want to have all these services running on the same
# machine. If you want to split them, then you cannot use this class.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::headnode {
  include dpm::nameserver
  include dpm::dpmserver
  include dpm::srm
  include dpm::client

  define domain {
    exec { "dpm_domain_$dpm_ns_host-$name":
      path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
      environment => [
        "DPNS_HOST=$dpm_ns_host", "DPNS_CONNTIMEOUT=5", "DPNS_CONRETRY=2", "DPNS_CONRETRYINT=1"
      ],
      command     => "dpns-mkdir -p /dpm/$name",
      unless      => "dpns-ls /dpm/$name",
      require     => [ Class["dpm::client"], Service["dpns"], ],
    }
  }

  define vo($domain) {
    $vo_path = "/dpm/$domain/home/$name"
    exec { "dpm_vo_$dpm_ns_host-$domain-$name":
      path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
      environment => [
        "DPNS_HOST=$dpm_ns_host", "DPNS_CONNTIMEOUT=5", "DPNS_CONRETRY=2", "DPNS_CONRETRYINT=1"
      ],
      command     => "dpns-mkdir -p $vo_path; dpns-chmod 755 $vo_path; dpns-entergrpmap --group $name; dpns-chown root:$name $vo_path; dpns-chmod 775 $vo_path",
      unless      => "dpns-ls /dpm/$domain/home/$name",
      require     => [ Class["dpm::client"], Service["dpns"], ],
    }
  }

  define pool {
    exec { "dpm_pool_$dpm_host-$name":
      path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
      environment => [
        "DPM_HOST=$dpm_host", "DPM_CONNTIMEOUT=5", "DPM_CONRETRY=2", "DPM_CONRETRYINT=1"
      ],
      command     => "dpm-addpool --poolname $name",
      unless      => "dpm-qryconf | grep 'POOL $name '",
      require     => [ Class["dpm::client"], Service["dpm"], ],
    }
  }
}
