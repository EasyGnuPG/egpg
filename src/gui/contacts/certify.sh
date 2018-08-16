gui_contacts_certify(){
    contact_id=$1
    details=$(yad --title="EasyGnuPG | Certify" \
        --text="Enter certification details:" \
        --form \
        --columns=2 \
        --field="Level":CB unknown\!onfaith\!casual\!extensive \
        --field="Certificaion Expiry":DT\
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10) || return 1

    # TODO: Add option for no expiry; May be a checkbox
    # TODO: Add checkbox for publish
    level=$(echo $details | cut -d'|' -f1)
    exp_time=$(echo $details | cut -d'|' -f2)
    days=$(( ($(date -d "$exp_time" "+%s") - $(date "+%s") )/(60*60*24) ))
    echo $level $days > /dev/tty
    output=$(call cmd_contact_certify "$contact_id" -l "$level" -t "${days}d" 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    # TODO improve messages
    if [[ $err == 0 ]]; then
        message info "Contact $contact_id certified as $level!"
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to certify contact $contact_id.\n <tt>$fail_details</tt>" 
        return 1
    fi
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2018 Dashamir Hoxha,
# Divesh Uttamchandani
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