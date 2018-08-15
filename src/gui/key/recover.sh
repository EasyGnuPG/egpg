gui_key_recover() {
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
    call cmd_key_recover $key1 $key2
}