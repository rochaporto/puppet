class dpm::disknode {
  include dpm::gridftp
  include dpm::rfio
  include dpm::client

  define loopback($fs, $blocks, $bs="1M", $type="ext3") {
    $file = "$fs-partition-file"

    file { "loopback_$fqdn-$fs":
      path   => $fs,
      owner  => dpmmgr,
      group  => dpmmgr,
      mode   => 770,
      ensure => directory,
    }

    file { "loopback_$fqdn-$file":
      path    => $file,
      owner   => dpmmgr,
      group   => dpmmgr,
      mode    => 770,
      require => Exec["dpm_loop_dd_$fqdn-$fs"],
    }

    exec { 
      "dpm_loop_dd_$fqdn-$fs":
        path    => "/usr/bin:/usr/sbin:/bin:/sbin",
        command => "dd if=/dev/zero of=$file bs=$bs count=$blocks",
        creates => $file;
      "dpm_loop_mkfs_$fqdn-$fs":
        path    => "/usr/bin:/usr/sbin:/bin:/sbin",
        command => "mkfs.$type -F $file",
        unless  => "df | grep $fs",
        require => [
          Exec["dpm_loop_dd_$fqdn-$fs"],
          File["loopback_$fqdn-$fs"],
        ];
      "dpm_loop_mount_$fqdn-$fs":
        path    => "/usr/bin:/usr/sbin:/bin:/sbin",
        command => "mount -o loop $file $fs; chmod 770 $fs; chown dpmmgr.dpmmgr $fs",
        unless  => "df | grep $fs",
        require => [
          Exec["dpm_loop_mkfs_$fqdn-$fs"],
          File["loopback_$fqdn-$fs"],
          File["loopback_$fqdn-$file"],
        ];
    }

    augeas { "loopback_augeas_$fqdn-$fs":
      changes => [
        "set /files/etc/fstab/01/spec $file",
        "set /files/etc/fstab/01/file $fs",
        "set /files/etc/fstab/01/vfstype $type",
        "set /files/etc/fstab/01/opt loop",
        "set /files/etc/fstab/01/dump 0",
        "set /files/etc/fstab/01/passno 0",
      ],
      onlyif  => "match /files/etc/fstab/*[file = '$fs'] size == 0",
      require => Exec["dpm_loop_mkfs_$fqdn-$fs"],
    }
  }

  define filesystem($fs, $pool) {
    exec { "dpm_filesystem_$fqdn-$fs":
      path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
      environment => [
        "DPM_HOST=$dpm_host", "DPM_CONNTIMEOUT=5", "DPM_CONRETRY=2", "DPM_CONRETRYINT=1"
      ],
      command     => "dpm-addfs --poolname $pool --server $fqdn --fs $fs",
      unless      => "dpm-qryconf | grep '  $fqdn $fs '",
      require     => Class["dpm::client"],
    }
  }
}


