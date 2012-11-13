# site.pp

node "rocha-el6.cern.ch" {
  include dms::nightlies::repo
}

