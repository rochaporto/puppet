# site.pp
import 'nodes.pp'

class slc5 {
	yumrepo { 'dpm-mysql-unstable-etics':
		baseurl => "http://etics-repository.cern.ch/repository/pm/volatile/repomd/name/lcgdm_unstable_sl5_x86_64_gcc412",
		gpgcheck => 0,
		enabled => 1,
	}
}
