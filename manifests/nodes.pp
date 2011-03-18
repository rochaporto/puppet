# nodes.pp
import 'nodes.passwd'

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
    include cern::base::hostcert
    include cern::base::afs

    Package { require => Yumrepo["lcgdm-unstable-etics", "epel"] }
}

node service inherits default {
    include voms::atlas
    include voms::dteam
 
    cern::base::afs::user { ["rocha"]: }
}

#
# Client node(s)
#
node 'vmdm0008.cern.ch' inherits default {
    include dpm::client
}

#
# DPM Head Node(s)
#
node 'vmdm0001.cern.ch' inherits service {
    include dpm::headnode

    # setup supported domain/vo(s)
    dpm::headnode::domain { 'cern.ch': require => Service['dpns'], }
    dpm::headnode::vo { 'dteam': domain => 'cern.ch', require => Dpm::Headnode::Domain['cern.ch'], }

    # setup pools
    dpm::headnode::pool { 'pool1': require => Service['dpm'] }
    dpm::headnode::pool { 'pool2': require => Service['dpm'] }

    dpm::shift::trust_entry { "tentry_dpns": component => "DPNS", }
    dpm::shift::trust_entry { "tentry_dpm": component => "DPM", }
    dpm::shift::trust_value { 
	"tvalue_dpns_0002":
            component => "DPNS", host => "vmdm0002.cern.ch", require => Dpm::Shift::Trust_entry["tentry_dpns"];
	"tvalue_dpm_0002":
            component => "DPM", host => "vmdm0002.cern.ch", require => Dpm::Shift::Trust_entry["tentry_dpm"];
	"tvalue_dpns_0009":
            component => "DPNS", host => "vmdm0009.cern.ch", require => Dpm::Shift::Trust_entry["tentry_dpns"];
	"tvalue_dpm_0009":
            component => "DPM", host => "vmdm0009.cern.ch", require => Dpm::Shift::Trust_entry["tentry_dpm"];
    }
}

#
# DPM Disk Node(s)
#
node 'vmdm0002.cern.ch', 'vmdm0009.cern.ch' inherits service {
    include dpm::disknode

    # setup filesystems (we use loopback partitions as this is a testing VM machine)
    dpm::disknode::loopback { "dpmfs1": fs => "/dpmfs1", blocks => 5000, }
    dpm::disknode::filesystem { "dpmfs1": fs => "/dpmfs1", pool => 'pool1', }

    dpm::disknode::loopback { "dpmfs2": fs => "/dpmfs2", blocks => 5000, }
    dpm::disknode::filesystem { "dpmfs2": fs => "/dpmfs2", pool => 'pool1', }
}

#
# DMS Build Node
#
node 'vmdm0006.cern.ch' {
    include dms::build
}
