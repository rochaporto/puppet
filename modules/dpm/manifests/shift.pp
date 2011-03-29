# Class managing the shift (libshift) configuration, used by the DPM/LFC for authorization.
#
# It includes definitions for creating new entries, updating existing ones, and
# assigning different kinds of trust relationships between nodes.
# 
# == Examples
#
# TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class dpm::shift {

  define entry($component, $type) {
    augeas { "shiftentry_$component-$type":
      changes => [
          "set /files/etc/shift.conf/01/name $component",
          "set /files/etc/shift.conf/01/type $type",
      ],
      onlyif => "match /files/etc/shift.conf/*[name='$component' and type='$type'] size == 0",
      require => [ File["/usr/share/augeas/lenses/dist/shift.aug"], File["/etc/shift.conf"], ],
    }
  }

  define value($component, $type, $value) {

    augeas { "shiftvalue_$component-$type-$value":
      changes => [
          "set /files/etc/shift.conf/*[name='$component' and type='$type']/value[0] $value",
      ],
      onlyif  => "match /files/etc/shift.conf/*[name='$component' and type='$type' and value='$value'] size == 0",
      require => [ File["/usr/share/augeas/lenses/dist/shift.aug"], File["/etc/shift.conf"], ]
  }
  }

  define trust_entry($component, $all=false, $type='TRUST') {
    if $all {
      entry { 
        "entryt_$component": component => $component, type => "TRUST";
        "entrytr_$component": component => $component, type => "RTRUST";
        "entrytw_$component": component => $component, type => "WTRUST";
        "entrytx_$component": component => $component, type => "XTRUST";
        "entrytf_$component": component => $component, type => "FTRUST";
      }
    } else {
      entry { "tentry_$component": component => $component, type => $type, }
    }
  }

  define trust_value($component, $host, $all=false, $type='TRUST') {
    if $all {
      value { 
        "valuet_$component-$host": component => $component, type => "TRUST", value => $host;
        "valuetr_$component-$host": component => $component, type => "RTRUST", value => $host;
        "valuetw_$component-$host": component => $component, type => "WTRUST", value => $host;
        "valuetx_$component-$host": component => $component, type => "XTRUST", value => $host;
        "valuetf_$component-$host": component => $component, type => "FTRUST", value => $host;
      }
    } else {
      value { "trust_$component-$host-$type": component => $component, type => $type, value => $host, }
    }
  }

  define protocol($component, $proto) {
    value { "protocol_$component-$proto": component => $component, type => "PROTOCOLS", value => $proto, }
  }

}
