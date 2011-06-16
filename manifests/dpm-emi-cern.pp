# dpm-emi-cern.pp
import 'dpmcern.passwd'

import 'cern'
import 'dms'
import 'dpm'
import 'voms'
import 'nagios'

#
# Generic node definitions
#
node cern-emi-service {
#
# Cluster configuration (global values)
#
$dpm_user = "dpmmgr"
$dpm_group = "dpmmgr"
$dpm_ns_host = "dpm-emi01.cern.ch"
$dpm_host = "dpm-emi01.cern.ch"

#
# DPM server configuration
#
$dpm_dbuser = 'dpmmgr'
$dpm_dbhost = 'localhost'
$dpm_run = "yes"
$dpm_ulimit = 4096
$dpm_coredump = "yes"
$dpm_configfile = "/usr/etc/DPMCONFIG"
$dpm_logfile = "/var/log/dpm/log"
$dpm_gridmapdir = "/etc/grid-security/gridmapdir"

#
# SRM server configuration
#
$dpm_srm_run = "yes"
$dpm_srm_ulimit = 4096
$dpm_srm_coredump = "yes"
$dpm_srm_logfile = "/var/log/srmv2.2/log"
$dpm_srm_gridmapdir = "/etc/grid-security/grid-mapfile"
$dpm_srm_gridmapfile = "/etc/grid-security/gridmapdir"

#
# RFIO server configuration
#
$dpm_rfio_run = "yes"
$dpm_rfio_ulimit = 4096
$dpm_rfio_logfile = "/var/log/rfio/log"
$dpm_rfio_gridmapdir = "/etc/grid-security/grid-mapfile"
$dpm_rfio_portrange = "20000 25000"
$dpm_rfio_options = "-sl"

#
# GSIFTP server configuration
#
$dpm_gsiftp_run = "yes"
$dpm_gsiftp_logfile = "/var/log/dpm-gsiftp/dpm-gsiftp.log"
$dpm_gsiftp_portrange = "20000 25000"
$dpm_gsiftp_options = "-S -d all -p 2811 -auth-level 0 -dsi dpm -disable-usage-stats"

#
# Nameserver configuration
#
$dpm_ns_dbuser = 'dpmmgr'
$dpm_ns_dbhost = 'localhost'
$dpm_ns_run = "yes"
$dpm_ns_readonly = "no" 
$dpm_ns_ulimit = 4096 
$dpm_ns_coredump = "yes" 
$dpm_ns_configfile = "/usr/etc/NSCONFIG" 
$dpm_ns_logfile = "/var/log/dpns/log" 
$dpm_ns_numthreads = 20 

#
# NFS frontend configuration
#
$dpm_nfs_exportid = 77
$dpm_nfs_exportpath = "/dpm/cern.ch"
$dpm_nfs_root_access = "localhost"
$dpm_nfs_pseudopath = "/"
$dpm_nfs_accesstype = "RW"
$dpm_nfs_sectype = "sys,krb5,krb5i,krb5p"
$dpm_nfs_fsid = "100.1"
$dpm_nfs_cachefiledata = "FALSE"
$dpm_nfs_maxfscalls = 10

#
# SEMsg DPM configuration
#
$semsg_dpm_run = "yes"
$semsg_dpm_coredump = "yes"
$semsg_dpm_brokeruri = "tcp://dev.msg.cern.ch:6166?wireFormat=openwire"

# TODO: replace this with an exported resource, so that disk nodes simply publish themselves
$disk_nodes = ["dpm-emi02.cern.ch dpm-emi03.cern.ch"]

  Package { require => Yumrepo["lcgdm-head-emi-etics", "emi-base", "epel"] }

  include dms::emi::head
  include grid-common::gridmap
  include cern::slc5
  include cern::hostcert
  include cern::afs
}

node dpm-emi-service inherits cern-emi-service {
  include voms::atlas
  include voms::dteam

  cern::afs::user { ["rocha","aalvarez","prodrigu","baud","okeeble","abeche"]: }
  cern::keytab { "keytab-nfs": serviceType => "nfs" }
}

#
# DPM Head Node(s)
#
node 'dpm-emi01.cern.ch' inherits dpm-emi-service {
  include dpm::headnode
  #include dpm::nagios::headnode

  # setup supported domain/vo(s)
  dpm::headnode::domain { 'cern.ch': require => Service['dpns'], }
  dpm::headnode::vo { 'dteam': domain => 'cern.ch', require => Dpm::Headnode::Domain['cern.ch'], }
  dpm::headnode::vo { 'atlas': domain => 'cern.ch', require => Dpm::Headnode::Domain['cern.ch'], }

  # setup pools
  dpm::headnode::pool { 'pool1': require => Service['dpm'] }

  dpm::shift::trust_value { 
    "tvalue_dpns_02":
        component => "DPNS", host => "dpm-emi02.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpns"];
    "tvalue_dpm_02":
        component => "DPM", host => "dpm-emi02.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpm"];
    "tvalue_dpns_03":
        component => "DPNS", host => "dpm-emi03.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpns"];
    "tvalue_dpm_03":
        component => "DPM", host => "dpm-emi03.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpm"];
    "tvalue_dpns_pcitgs10":
        component => "DPNS", host => "pcitgs10.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpns"];
    "tvalue_dpm_pcitgs10":
        component => "DPM", host => "pcitgs10.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpm"];
    "tvalue_dpns_nagios":
        component => "DPNS", host => "vmdm0006.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpns"];
    "tvalue_dpm_nagios":
        component => "DPM", host => "vmdm0006.cern.ch", require => Dpm::Shift::Trust_entry["trustentry_dpm"];
  }
}

#
# DPM Disk Node(s)
#
node 'dpm-emi02.cern.ch', 'dpm-emi03.cern.ch' inherits dpm-emi-service {
  include dpm::disknode
  #include dpm::nagios::disknode

  # setup filesystems (we use loopback partitions as this is a testing VM machine)
  dpm::disknode::loopback { "dpmfs1": fs => "/dpmfs1", blocks => 10000, }
  dpm::disknode::filesystem { "dpmfs1": fs => "/dpmfs1", pool => 'pool1', }

  dpm::disknode::loopback { "dpmfs2": fs => "/dpmfs2", blocks => 10000, }
  dpm::disknode::filesystem { "dpmfs2": fs => "/dpmfs2", pool => 'pool1', }

  dpm::shift::trust_value { 
    "trustvalue_rfiod_pcitgs10": 
      component => "RFIOD", host => "pcitgs10.cern.ch", all => true, 
      require => Dpm::Shift::Trust_entry["trustentry_rfiod_all"];
    "trustvalue_rfiod_nagios": 
      component => "RFIOD", host => "vmdm0006.cern.ch", all => true, 
      require => Dpm::Shift::Trust_entry["trustentry_rfiod_all"];
  }
}

#
# DPM Client Node
#
node 'dpm-emi04.cern.ch' inherits dpm-emi-service {
  include lcgutil::client
  #include dpm::nfsclient
  include dpm::client
  #include dpm::nagios::client
  include voms::client
}
