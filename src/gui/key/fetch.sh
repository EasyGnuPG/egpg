gui_key_fetch() {
    homedir=$(yad --title="EasyGnuPG | Fetch" \
        --text="Fetch a key from another directory" \
        --form \
        --columns=2 \
        --field="Select .gnupg folder":DIR \
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10 | cut -d'|' -f1)
    output=$(call cmd_key_fetch --homedir=$homedir)

    err=$?
    is_true $DEBUG && echo "$output"

    if [[ $err == 0 ]]; then
        # TODO go to the key display interface (main) after closing this
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to fetch keys from $homedir.\n <tt>$fail_details</tt>" 
        return 1
    fi
}