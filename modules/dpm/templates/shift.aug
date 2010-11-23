(* Parsing /etc/shift.conf *)

module Shift =
  autoload xfm

  let sep_tab = Util.del_ws_tab
  let sep_spc = Util.del_ws_spc

  let eol = del /[ \t]*\n/ "\n"
  let indent = del /[ \t]*/ ""

  let comment = Util.comment
  let empty   = [ del /[ \t]*#?[ \t]*\n/ "\n" ]

  let word = /[^# \n\t]+/
  let record = [ seq "component" . indent .
                              [ label "name" . store  word ] . sep_tab .
                              [ label "type" . store word ] .
                              [ label "value" . sep_spc . store word ]*
                 . (comment|eol) ]

  let lns = ( empty | comment | record ) *

  let xfm = transform lns (incl "/etc/shift.conf")
