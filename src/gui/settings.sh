gui_settings() {
    local debug share gnupghome keyserver dongle
    is_true $DEBUG && debug=true
    is_true $SHARE && share=true
    # TODO: think something about dongle, dongle can use DIR field
    # but we always have a default value for this field. How to avoid this?

    # TODO: add EGPG_DIR to config, but it is difficult as it would require to
    # reload the settings box on changing EGPG_DIR. Also the config file may not
    # exist in the new EGPG_DIR 
    details=$(yad --title="EasyGnuPG | Settings" \
        --borders=10 \
        --form \
        --field="GNUPGHOME":DIR "$GNUPGHOME" \
        --field="DONGLE" "$DONGLE" \
        --field="KEYSERVER": "$KEYSERVER" \
        --field="SHARE":CHK "$share" \
        --field="DEBUG":CHK "$debug" \
        --button=gtk-save \
        --button=gtk-quit)
    echo $details > /dev/tty
    gnupghome=$(echo "$details" | cut -d'|' -f1)
    dongle=$(echo "$details" | cut -d'|' -f2)
    keyserver=$(echo "$details" | cut -d'|' -f3)
    share=$(echo "$details" | cut -d'|' -f4)
    debug=$(echo "$details" | cut -d'|' -f5)

    # TODO: we can call egpg set here
    # Also we can rewrite the complete config file instead of changing

    # TODO: Also check if config's GNUPGHOME is on priority one
    sed -i "$EGPG_DIR/config.sh" -e "/DEBUG=/c DEBUG=$debug"
    sed -i "$EGPG_DIR/config.sh" -e "/SHARE=/c SHARE=$share"
    call_fn gpg_send_keys
    sed -i "$EGPG_DIR/config.sh" -e "/GNUPGHOME=/c GNUPGHOME=\"$gnupghome\""
    sed -i "$EGPG_DIR/config.sh" -e "/KEYSERVER=/c KEYSERVER=\"$keyserver\""
    [[ -z "$dongle" ]] || (dongle=$(realpath $dongle) && sed -i "$EGPG_DIR/config.sh" -e "/DONGLE=/c DONGLE=\"$dongle\"")
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
