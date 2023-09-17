#!/usr/bin/env bash

set -e

provision_setup_zsh_unalias() {
  local LIST=(
    "g"
    "ga"
    "gam"
    "gama"
    "gamc"
    "gams"
    "gamscp"
    "gb"
    "gcb"
    "gco"
    "gd"
    "gf"
    "gfo"
    "ggpull"
    "ggpur"
    "ggpush"
    "ggsup"
    "ghh"
    "gignore"
    "gignored"
    "gk"
    "gke"
    "gl"
    "glg"
    "glgg"
    "glgga"
    "glgm"
    "glgp"
    "glo"
    "glod"
    "glods"
    "glog"
    "gloga"
    "glol"
    "glola"
    "glols"
    "glp"
    "gluc"
    "glum"
    "gm"
    "gma"
    "gmom"
    "gms"
    "gmtl"
    "gmtlvim"
    "gmum"
    "gob"
    "gp"
    "gpd"
    "gpf!"
    "gpoat"
    "gpod"
    "gpr"
    "gpsup"
    "gpu"
    "gpv"
    "gr"
    "gra"
    "grb"
    "grba"
    "grbc"
    "grbd"
    "grbi"
    "grbm"
    "grbo"
    "grbom"
    "grbs"
    "grev"
    "grh"
    "grhh"
    "grm"
    "grmc"
    "grmv"
    "groh"
    "grrm"
    "grs"
    "grset"
    "grss"
    "grst"
    "grt"
    "gru"
    "grup"
    "grv"
    "gsb"
    "gsd"
    "gsh"
    "gsi"
    "gsps"
    "gsr"
    "gss"
    "gst"
    "gstaa"
    "gstall"
    "gstc"
    "gstd"
    "gstl"
    "gstp"
    "gsts"
    "gstu"
    "gsu"
    "gsw"
    "gswc"
    "gswd"
    "gswm"
    "gtl"
    "gts"
    "gtv"
    "gunignore"
    "gunwip"
    "gup"
    "gupa"
    "gupav"
    "gupom"
    "gupomi"
    "gupv"
    "gwch"
    "gwip"
    "gwt"
    "gwta"
    "gwtls"
    "gwtmv"
    "gwtrm"
  )
  local TEXT=""

  for LIST_ITEM in "${LIST[@]}"; do
    TEXT="$TEXT
unalias -m '$LIST_ITEM'"
  done
  echo "$TEXT" >>~/.zshrc
}