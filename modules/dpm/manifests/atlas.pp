class dpm::atlas {
  include voms::atlas
  include dpm::lcgdmmap

  # grid-mapfile mapping to local account (we use nobody, no pool accounts needed)
  glite::gridmap::group { "voms_atlas_cern":
    file     => "/opt/edg/etc/edg-mkgridmap.conf",
    voms_uri => "vomss://voms.cern.ch:8443/voms/atlas?/atlas",
    map      => "nobody",
  }

  # Mapping user to VO for case of proxies with no VOMS info
  glite::gridmap::group { "dpm_atlas_cern":
    file     => "/opt/lcg/etc/lcgdm-mkgridmap.conf",
    voms_uri => "vomss://voms.cern.ch:8443/voms/atlas?/atlas",
    map      => "atlas",
  }
}
