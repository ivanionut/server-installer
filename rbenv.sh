#!/usr/bin/env bash

wget -N --quiet https://raw.github.com/pierot/server-installer/master/lib.sh; . ./lib.sh

###############################################################################

install_name='rbenv'

###############################################################################

_redirect_stdout 'rbenv'
_check_root
_print_h1 $install_name

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


_rbenv() {
	_print_h2 "Installing RBENV"

  # Delete when exists
  rm -rf $HOME/.rbenv

  _print "Cloning rbenv git repo"
  # Clone into
  git clone git://github.com/sstephenson/rbenv.git $HOME/.rbenv

  _print "Install ruby-build"
  # Install Ruby-Build
  mkdir -p $HOME/.rbenv/plugins

  git clone git://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build

  $HOME/.rbenv/plugins/ruby-build/install.sh

  source $HOME/.bash_profile

  _print "Install ruby 1.9.3-p125"
  rbenv install 1.9.3-p125
  rbenv global 1.9.3-p125

  _print "Rbenv rehash"
  rbenv rehash
}

_gem_config() {
	_print_h2 "Updating Rubygems"

  gem update --system

	_print "Adding no-rdoc and no-ri rules to gemrc"

	gemrc_settings="
---\n
:verbose: true\n
:bulk_threshold: 1000\n
install: --no-ri --no-rdoc --env-shebang\n
:sources:\n
- http://gemcutter.org\n
- http://gems.rubyforge.org/\n
- http://gems.github.com\n
:benchmark: false\n
:backtrace: false\n
update: --no-ri --no-rdoc --env-shebang\n
:update_sources: true\n
"

  sudo touch /etc/skel/.gemrc
  sudo touch ~/.gemrc

  echo -e $gemrc_settings | sudo tee -a /etc/skel/.gemrc > /dev/null
  echo -e $gemrc_settings | sudo tee -a ~/.gemrc > /dev/null

	_print "Installing Bundler"

  gem install bundler
}

###############################################################################

_rbenv
_gem_config

_note_installation "base"
