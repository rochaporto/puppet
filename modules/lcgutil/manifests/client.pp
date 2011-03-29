# Manages (installs) all required resources for a LCGUTIL client.
# 
# == Examples
#
# Simply include this class, as in:
#   include lcgutil::client
# 
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class lcgutil::client {
    package { "lcg_util": ensure => latest, notify => Exec["glite_ldconfig"], }
}
