message() {
    local type=${1:-info}; shift
    local text="$@"
    yad --title "EasyGnuPG | ${type^} Message" \
        --text "$text" \
        --button=gtk-close \
        --image=gtk-dialog-${type,,} \
        --borders=10 \
        --skip-taskbar \
        --close-on-unfocus \
        --timeout=10
}

key_info() {
    local id=$1
    local info=$(gpg --list-keys --fingerprint --with-sig-check --with-colons $id)

    local uid=$(echo "$info" | grep -E '^uid:[^r]:' | head -1 | cut -d: -f10 | tr '<>' '()')
    local fpr=$(echo "$info" | grep '^fpr:' | head -1 | cut -d: -f10 | sed 's/..../\0 /g')

    local time1=$(echo "$info" | grep -E '^(pub|sub):[^r]:' | head -1 | cut -d: -f6)
    local time1=$(echo "$info" | grep -E '^(pub|sub):[^r]:' | head -1 | cut -d: -f7)
    local creation=$(date -d @$time1 +%F)
    local expiration='never'
    [[ -n $time2 ]] && expiration=$(date -d @$time2 +%F)

    cat << _EOF_
<big><tt>
<b>Label:</b>       Personal Key ($id)
<b>Identity:</b>    $uid
<b>Fingerprint:</b> $fpr
<b>Creation:</b>    $creation
<b>Expiration:</b>  $expiration
</tt></big>
_EOF_
}

pango_raw(){
    sed -e "s/</\&lt;/" -e "s/>/\&gt;/"
}

get_contacts() {
    local ids output info
    ids=$(gpg --list-keys --with-colons "$@" | grep '^pub' | cut -d: -f5)
    source "$LIBDIR/fn/print_key.sh"
    for id in $ids; do
        info=$(print_key $id)
        uids=$(echo "$info" | grep "^uid:" | cut -d: -f2 | pango_raw)
        output="$output$id\n$uids\n"
    done
    echo -e $output | head -c -1
}

select_contacts() {
    get_contacts "$@" | yad --title="EasyGnuPG | Select Contacts" \
    --list \
    --multiple \
    --width=600 \
    --height=450 \
    --column="ID" \
    --column="UID(s)" \
    --button="Details":'bash -c "gui contacts_details $(head -n 1 $tmpfile)"' \
    --button="Add Contact":'bash -c "gui contacts_add"' \
    --button=gtk-ok \
    --select-action='bash -c "on_select %s"'\
    --dclick-action='bash -c "gui contacts_details $(head -n 1 $tmpfile)"'\
    --no-rules-hint
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2018 Dashamir Hoxha
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
