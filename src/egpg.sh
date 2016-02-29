#!/usr/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

GNUPGHOME="${GNUPGHOME:-$(gpgconf --list-dirs | grep ^homedir | sed 's/^[^:]*://')}"

### dev
export GNUPGHOME="$(pwd)/.gnupg"
if [[ ! -d $GNUPGHOME ]]; then
    mkdir -p $GNUPGHOME
    chmod 700 $GNUPGHOME
fi

colon_field(){
  echo $2 | cut -d: -f${1}
}

#Set a useful default for the GnuPG program
GNUPG=$(which gpg2)
if [ -z ${GNUPG} ]; then
  GNUPG=$(which gpg)
fi
if [ -z ${GNUPG} ]; then
  echo "Cannot find gpg or gpg2! Do you have gnupg installed?"
fi

get_my_key(){
  MY_KEY=$(colon_field 3 $($GNUPG --gpgconf-list | grep ^default-key))
  if [ -z $MY_KEY ]; then
    MY_KEY=$(colon_field 5 $($GNUPG --list-secret-keys --with-colons | grep ^sec | head -n 1))
  fi
}
get_my_key

if [ -z $MY_KEY ]; then
  echo "Hm. I can't find a secret key for you - this isn't going to be very useful until you get one set up."
  echo "Try: $0 help generate"
fi

#Dispatch the command - commands are listed explicitly to avoid errors
egpg_root=$(dirname $0)
find_subcommand() {
  case $1 in
    seal)
      subcommand_name="seal"
      subcommand_path="${egpg_root}/commands/seal" ;;
    open)
      subcommand_name="open"
      subcommand_path="${egpg_root}/commands/open" ;;
    generate)
      subcommand_name="generate"
      subcommand_path="${egpg_root}/commands/generate" ;;
    fingerprint)
      subcommand_name="fingerprint"
      subcommand_path="${egpg_root}/commands/fingerprint" ;;
    help)
      subcommand_name="help"
      subcommand_path="${egpg_root}/commands/help" ;;
    *)
      echo "Unknown command: ${subcommand}"
      echo
      subcommand_name=""
      subcommand_path="${egpg_root}/commands/help" ;;
  esac
}

fail() {
  echo $1
  echo
  help_text
  exit 1
}

help_text(){
  echo -n "$0 $subcommand_name "
  usage
}

run() {
  setup "$@"
  validate
  invoke
  if [ $? -eq 0 ]; then
    echo
    success
  else
    echo
    failure
  fi
}

subcommand=$1
shift
find_subcommand $subcommand
source $subcommand_path
run "$@"
