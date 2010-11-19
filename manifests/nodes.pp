# nodes.pp

import 'cern'
import 'dms'
import 'dpm'
import 'voms'

#
# Cluster configuration (global values)
#
$dpm_ns_host = "vmdm0001.cern.ch"
$dpm_host = "vmdm0001.cern.ch"

#
# DPM server configuration
#
$dpm_dbuser = 'dpmmgr'
$dpm_dbpass = 'dpmmgr'
$dpm_dbhost = 'localhost'
$dpm_run = "yes"
$dpm_ulimit = 4096
$dpm_coredump = "yes"
$dpm_configfile = "/opt/lcg/etc/DPMCONFIG"
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
# RFIO server configuration
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
$dpm_ns_configfile = "/opt/lcg/etc/NSCONFIG" 
$dpm_ns_logfile = "/var/log/dpns/log" 
$dpm_ns_numthreads = 20 

# TODO: replace this with an exported resource, so that disk nodes simply publish themselves
$disk_nodes = ["vmdm0002.cern.ch vmdm0009.cern.ch"]

#
# Generic node definitions
#
node default {
    include dms::unstable
    include glite::gridmap

    Package { require => Yumrepo["dpm-mysql-unstable-etics", "epel"] }
}

node service inherits default {
    include voms::atlas
    include voms::dteam
}

#
# Client node(s)
#
node 'vmdm0008.cern.ch' inherits default {
    include dpm::client
}

# DPM Head Node(s)
node 'vmdm0001.cern.ch' inherits service {
    include dpm::headnode

    # setup supported domain/vo(s)
    dpm::headnode::domain { 'cern.ch': require => Service['dpns'], }
    dpm::headnode::vo { 'dteam': domain => 'cern.ch', require => Dpm::Headnode::Domain['cern.ch'], }

    # setup pools
    dpm::headnode::pool { 'pool1': require => Service['dpm'] }
    dpm::headnode::pool { 'pool2': require => Service['dpm'] }
}

#
# DPM Disk Node(s)
#
node 'vmdm0002.cern.ch', 'vmdm0009.cern.ch' inherits service {
    include dpm::disknode

    # setup filesystems (we use loopback partitions as this is a testing VM machine)
    dpm::disknode::loopback { '/dpmfs1': blocks => 5000, }
    dpm::disknode::filesystem { '/dpmfs1': pool => 'pool1', }

    dpm::disknode::loopback { '/dpmfs2': blocks => 5000, }
    dpm::disknode::filesystem { '/dpmfs2': pool => 'pool2', }
}

