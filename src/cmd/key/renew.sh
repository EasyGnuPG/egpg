#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2016 Dashamir Hoxha
#
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
# along with this program.  If not, see http://www.gnu.org/licenses/
#

cmd_key_renew() {
    local expdate="$@"
    if [[ -z "$expdate" ]]; then
        # default is 1 month
        time="1m"
    else
        # calculate the number of days from now until the given time
        local expday=$(date -d "$expdate" +%s)
        local today=$(date -d $(date +%F) +%s)
        time=$(( ( $expday - $today ) / 86400 ))
    fi

    local commands=";expire;$time;y"
    commands+=";key 1;expire;$time;y;key 1"
    commands+=";key 2;expire;$time;y;key 2"
    commands+=";key 3;expire;$time;y;key 3"
    commands+=";save"
    commands=$(echo "$commands" | tr ';' "\n")

    get_gpg_key
    script -c "gpg --command-fd=0 --key-edit $GPG_KEY <<< \"$commands\" " /dev/null > /dev/null
    gpg_send_keys $GPG_KEY

    call cmd_key_list
}
