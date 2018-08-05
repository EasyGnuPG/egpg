gui_key_restore() {
    file=$(yad --title="EasyGnuPG | Restore" \
        --text="Retore a key from backup file" \
        --form \
        --columns=2 \
        --field="File":SFL /root \
        --button=gtk-yes \
        --button=gtk-quit \
        --borders=10 | cut -d'|' -f1) || return 1
    call cmd_key_restore $file
}