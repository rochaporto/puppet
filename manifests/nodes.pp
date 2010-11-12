# nodes.pp

import 'dpm'

node default {
}

node slc5 inherits default {
	include slc5
}

node 'vmdm0001.cern.ch' inherits slc5 {
	include dpm::dpns
}

