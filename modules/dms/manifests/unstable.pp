# Class defining resources for CERN/IT/DMS unstable setups.
#
# Meaning these setups are supposed to use packages which are experimental
# or still under certification.
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
class dms::unstable {

  package { "yum-protectbase": }

  package { "lcgdm-libs": require => Package["yum-protectbase"] }

  yumrepo { 
    "lcgdm-head-etics":
      descr    => "LCGDM ETICS Unstable Repository",
      baseurl  => "http://etics-repository.cern.ch/repository/pm/volatile/repomd/name/lcgdm_head_sl5_x86_64_gcc412",
      gpgcheck => 0,
      enabled  => 1,
      protect  => 0;
    "lcgdm-unstable-etics":
      descr    => "LCGDM ETICS Unstable Repository",
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

