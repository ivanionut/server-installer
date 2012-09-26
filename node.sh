#!/usr/bin/env bash

install_name='node'

###############################################################################

wget -N --quiet https://raw.github.com/pierot/server-installer/master/lib.sh; . ./lib.sh

_redirect_stdout $install_name
_check_root

###############################################################################

_usage() {
  _print "

Usage:              $install_name.sh -h

Remote Usage:       bash <( curl -s https://raw.github.com/pierot/server-installer/master/$install_name.sh )

Options:
 
  -h                Show this message
  "

  exit 0
} 

###############################################################################

while getopts :hs:n:d:e: opt; do 
  case $opt in
    h)
      _usage
      ;;
    *)
      _error "Invalid option received"

      _usage

      exit 0
      ;;
  esac 
done

###############################################################################

_node() {
	_log "Install $install_name"

  _log "***** Install dependencies"

  _system_installs_install 'g++ curl libssl-dev apache2-utils'

  cd $temp_dir

  _log "***** Clone node"
  git clone git://github.com/joyent/node.git
  cd node

  _log "***** Configure & make & make install"
  ./configure
  make
  sudo make install
}

###############################################################################

_node $nginx_version

_note_installation $install_name