#!/usr/bin/env bash

wget -N --quiet https://raw.github.com/pierot/server-installer/master/lib.sh; . ./lib.sh

###############################################################################

install_name='rvm'

###############################################################################

_redirect_stdout $install_name
_check_root
_print_h1 "Installing RVM System wide"

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


_rvm() {
  _print_h2 "Execute install-system-wide for rvm"

  # sudo su -c bash < <( curl -L https://raw.github.com/wayneeseguin/rvm/1.3.0/contrib/install-system-wide )
  curl -L get.rvm.io | sudo bash -s stable

  _print "Add sourcing of rvm in ~/.bashrc"

  ps_string='[ -z "$PS1" ] && return'
  search_string='s/\[ -z \"\$PS1\" \] \&\& return/if [[ -n \"\$PS1\" ]]; then/g'
  rvm_bin_source="fi\n
  if groups | grep -q rvm ; then\n
    source '/usr/local/rvm/scripts/rvm'\n
  fi\n
  "
  # rvm_bin_source="fi\n
  # if groups | grep -q rvm ; then\n
  #   source '/usr/local/lib/rvm'\n
  # fi\n
  # "

  if [ -f ~/.bashrc ]; then
    sudo perl -pi -e "$search_string" ~/.bashrc

    echo -e $rvm_bin_source | sudo tee -a ~/.bashrc > /dev/null
  fi

  _print "Add sourcing of rvm in /etc/skel/.bashrc"

  if [ -f /etc/skel/.bashrc ]; then
    sudo perl -pi -e "$search_string" /etc/skel/.bashrc
  else
    sudo sh -c "$ps_string > /etc/skel/.bashrc"
  fi

  echo -e $rvm_bin_source | sudo tee -a /etc/skel/.bashrc > /dev/null

  _print "Now source!"

  source /usr/local/rvm/scripts/rvm

  _print "Add bundler to global.gems"

  sudo sh -c 'echo "bundler" >> /usr/local/rvm/gemsets/global.gems'

  _print "Reload shell"

  rvm reload

  _print "Install Readline package shell"

  rvm pkg install readline

  _print "Installing Ruby 1.8.7"

  rvm install 1.8.7

  _print "Installing Ruby 1.9.3 (default)"

  rvm install 1.9.3
  rvm --default use 1.9.3
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

  rvm gemset use global

  gem install bundler

  rvm gemset clear
}

###############################################################################

_rvm
_gem_config

_the_end

_note_installation "base"
