gui_key_restore() {
    local file output err
    file=$(yad --title="EasyGnuPG | Restore" \
        --text="Retore a key from backup file" \
        --form \
        --columns=2 \
        --field="File":SFL /root \
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10 | cut -d'|' -f1) || return 1
    output=$(call cmd_key_restore $file 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    if [[ $err == 0 ]]; then
        # TODO go to the key display interface (main) after closing this
        # and remove this  message
        message info "key restored successfully"
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to resotre key.\n <tt>$fail_details</tt>" 
        return 1
    fi
}