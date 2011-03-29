#
# dpm/init.pp
#
import "glite"
import "mysql"

#
# Class: dpm
#
# This class manages DPM nodes.
#
# Parameters:
#
#   - Cluster configuration
#   $dpm_ns_host 	= <hostname of machine running the DPM nameserver> : e.g 'dpns.cern.ch'
#   $dpm_host 		= <hostname of machine running the DPM service>    : e.g 'dpm.cern.ch'
#
#   - Nameserver configuration
#   $dpm_ns_dbuser 	= <database user name> : e.g. 'dpmmgr' 
#   $dpm_ns_dbpass 	= <database password>  : e.g. 'mypassword'
#   $dpm_ns_dbhost 	= <database hostname>  : e.g. 'localhost'
#   $dpm_ns_run 	= <should the nameserver run?> : default 'yes'
#   $dpm_ns_readonly 	= <run nameserver read only>   : default 'no'
#   $dpm_ns_ulimit 	= <limit for file descriptors> : default 4096 
#   $dpm_ns_coredump 	= <allow core dump>            : default 'yes'
#   $dpm_ns_configfile	= <db config file>             : default '/opt/lcg/etc/NSCONFIG'
#   $dpm_ns_logfile 	= <log file>                   : default '/var/log/dpns/log'
#   $dpm_ns_numthreads 	= <number of threads>          : default 20 
# 
#   - DPM server configuration
#   $dpm_dbuser 	= <database user name> : e.g. 'dpmmgr' 
#   $dpm_dbpass 	= <database password>  : e.g. 'mypassword'
#   $dpm_dbhost 	= <database hostname>  : e.g. 'localhost'
#   $dpm_run 		= <should the dpm server run?> : default 'yes'
#   $dpm_ulimit 	= <limit for file descriptors> : default 4096 
#   $dpm_coredump 	= <allow core dump>            : default 'yes'
#   $dpm_configfile	= <db config file>             : default '/opt/lcg/etc/NSCONFIG'
#   $dpm_logfile 	= <log file>                   : default '/var/log/dpns/log'
#   $dpm_gridmapdir     = <gridmap directory>          : default '/etc/grid-security/gridmapdir'
#
#   - SRM server configuration
#   $dpm_srm_run 		= <should the srm server run?> : default 'yes'
#   $dpm_srm_ulimit 		= <limit for file descriptors> : default 4096 
#   $dpm_srm_coredump 		= <allow core dump>            : default 'yes'
#   $dpm_srm_logfile 		= <log file>                   : default '/var/log/dpns/log'
#   $dpm_srm_gridmapdir     	= <gridmap directory>          : default '/etc/grid-security/gridmapdir'
#   $dpm_srm_gridmapfile    	= <gridmap file>               : default '/etc/grid-security/grid-mapfile'
#
#   - RFIO server configuration
#   $dpm_rfio_run 		= <should the rfio server run?> : default 'yes'
#   $dpm_rfio_ulimit 		= <limit for file descriptors>  : default 4096 
#   $dpm_rfio_logfile 		= <log file>                    : default '/var/log/dpns/log'
#   $dpm_rfio_portrange 	= <range of ports to listen>    : default '20000 25000'
#   $dpm_rfio_gridmapdir    	= <gridmap directory>           : default '/etc/grid-security/gridmapdir'
#   $dpm_rfio_options       	= <rfio daemon options>         : default '-sl'
#
#   - GSIFTP server configuration
#   $dpm_gsiftp_run 		= <should the gsiftp server run?> : default 'yes'
#   $dpm_gsiftp_logfile 	= <log file>                    : default '/var/log/dpm-gsiftp/dpm-gsiftp.log'
#   $dpm_gsiftp_portrange 	= <range of ports to listen>    : default '20000 25000'
#   $dpm_gsiftp_options       	= <gsiftp daemon options>       : default '-S -d all -p 2811 -auth-level 0 -dsi dpm -disable-usage-stats'
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dpm {
}
