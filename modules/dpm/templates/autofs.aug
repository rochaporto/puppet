(* Parsing /etc/auto.master *)

module Autofs =
  autoload xfm

  let sep_tab = Util.del_ws_tab
  let sep_spc = Util.del_ws_spc

  let eol = del /[ \t]*\n/ "\n"
  let indent = del /[ \t]*/ ""

  let comment = Util.comment
  let empty   = [ del /[ \t]*#?[ \t]*\n/ "\n" ]

  let word = /[^# \n\t]+/
  let simple = [ seq "component" . indent .
                              [ label "mnt" . store  word ]
                 . (comment|eol) ]
  let record = [ seq "component" . indent .
                              [ label "mnt" . store  word ] . sep_tab .
                              [ label "config" . store word ] .
                              [ label "options" . sep_spc . store word ]*
                 . (comment|eol) ]


  let lns = ( empty | comment | record | simple ) *

  let xfm = transform lns (incl "/etc/auto.master")

