gui_key_fetch() {
    homedir=$(yad --title="EasyGnuPG | Fetch" \
        --text="Fetch a key from another directory" \
        --form \
        --columns=2 \
        --field="Select .gnupg folder":DIR \
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10 | cut -d'|' -f1)
    call cmd_key_fetch --homedir=$homedir
}