class dpm::lcgdmmap {
  glite::gridmap::mkgridmap { "lcgdm-mkgridmap":
    conffile => "/opt/lcg/etc/lcgdm-mkgridmap.conf",
    mapfile  => "/opt/lcg/etc/lcgdm-mapfile",
    logfile  => "/var/log/lcgdm-mkgridmap.log",
  }
}
