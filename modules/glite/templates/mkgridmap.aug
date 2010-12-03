(* Parsing mkgridmap.conf *)

module Mkgridmap =
  autoload xfm

  let sep_tab = Util.del_ws_tab
  let sep_spc = Util.del_ws_spc

  let eol = del /[ \t]*\n/ "\n"
  let indent = del /[ \t]*/ ""

  let comment = Util.comment
  let empty   = [ del /[ \t]*#?[ \t]*\n/ "\n" ]

  let word = /[^# \n\t]+/
  let record = [ seq "group" . [ label "type" . store word ] . sep_spc .
                               [ label "uri" . store word ] . sep_spc .
                               [ label "map" . store word ]
                 . (comment|eol) ]

  let lns = ( empty | comment | record ) *

  let filter = (incl "/opt/edg/etc/edg-mkgridmap.conf")
        . (incl "/opt/lcg/etc/lcgdm-mkgridmap.conf")

  let xfm = transform lns filter
