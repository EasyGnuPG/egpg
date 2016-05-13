# Renew the key until the given date.

cmd_key_renew_help() {
    cat <<-_EOF
    renew,expiration [<date>]
        Renew the key until the given date (by default 1 month from now).
        The <date> is in free time format, like "2 months", 2020-11-15,
        "March 7", "5 years" etc. The date formats are those that are
        accepted by the command 'date -d' (see 'info date').

_EOF
}

cmd_key_renew() {
    get_gpg_key
    is_full_key || fail "
This key is split into partial keys.
Try first:  $(basename $0) key join
     then:  $(basename $0) key renew ...
      and:  $(basename $0) key split
"

    local expdate="$@"
    [[ -z "$expdate" ]] && expdate="1 month"

    # calculate the number of days from now until the given time
    local expday=$(date -d "$expdate" +%s)
    local today=$(date -d $(date +%F) +%s)
    time=$(( ( $expday - $today ) / 86400 ))

    local commands=";expire;$time;y;key 1;expire;$time;y;key 1;save"
    commands=$(echo "$commands" | tr ';' "\n")
    echo -e "$commands" | gpg --no-tty --command-fd=0 --key-edit $GPG_KEY 2>/dev/null
    call_fn gpg_send_keys $GPG_KEY

    call cmd_key_list
}

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
