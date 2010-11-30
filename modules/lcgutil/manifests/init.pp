# lcgutil/init.pp

import "glite"

# Class: lcgutil
# 
# This class provides definitions to manage a lcgutil installation.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class lcgutil {
    
    class client {
        package { "lcg_util": ensure => latest, notify => Exec["glite_ldconfig"], }
    }

}

