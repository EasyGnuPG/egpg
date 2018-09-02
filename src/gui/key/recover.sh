gui_key_recover() {
    local partials key1 key2 output err
    partials=$(yad --title="EasyGnuPG | Recover" \
        --text="Recover a key from partial files" \
        --form \
        --columns=2 \
        --field="Partial 1":SFL /root \
        --field="Partial 2":SFL /root \
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10) || return 1
    echo $partials > /dev/tty
    key1=$(echo $partials | cut -d'|' -f1)
    key2=$(echo $partials | cut -d'|' -f2)
    echo -e $key1 '\n' $key2 > /dev/tty
    
    output=$(call cmd_key_recover $key1 $key2)
    output=$(call cmd_key_restore $file 2>&1)
    err=$?
    is_true $DEBUG && echo "$output"

    if [[ $err == 0 ]]; then
        # TODO go to the key display interface (main) after closing this
        # and remove this message
        message info "Key recovered successfully"
    else
        fail_details=$(echo "$output" | grep '^gpg:' | uniq | pango_raw)
        message error "Failed to recover a key from given files.\n <tt>$fail_details</tt>" 
        return 1
    fi
}