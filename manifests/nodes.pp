# nodes.pp

import 'dpm'

#
# Cluster configuration (global values)
#
$dpm_ns_host = "vmdm0001.cern.ch"
$dpm_host = "vmdm0001.cern.ch"

#
# Nameserver configuration
#
$dpm_ns_dbuser = 'dpmmgr'
$dpm_ns_dbpass = 'dpmmgr'
$dpm_ns_dbhost = 'localhost'

$dpm_ns_run = "yes"
$dpm_ns_readonly = "no" 
$dpm_ns_ulimit = 4096 
$dpm_ns_coredump = "yes" 
$dpm_ns_configfile = "/opt/lcg/etc/NSCONFIG" 
$dpm_ns_logfile = "/var/log/dpns/log" 
$dpm_ns_numthreads = 20 

#
# Node definition
#
node default {
}

node slc5 inherits default {
	include slc5
}

node 'vmdm0001.cern.ch' inherits slc5 {
	include dpm::headnode
}
