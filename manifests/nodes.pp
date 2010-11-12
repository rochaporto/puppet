# nodes.pp

import 'dpm'

node default {

}

node 'vmdm0001.cern.ch' inherits default {
	include slc5
	include dpm::dpns
}

