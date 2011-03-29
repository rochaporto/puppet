# Installs and configures a NFS client, performing any additional required
# setup for a glite enabled NFS client.
# 
# == Examples
#
# Simply include this class, as in:
#  include glite::nfsclient 
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class glite::nfsclient {
  package { 
    "kernel-pnfs": ensure => latest;
    "nfs-utils": ensure => "1.2.3-1";
  }
}
