error_msg() {
    yad --title "Error" \
        --text "$@" \
        --button=gtk-close \
        --image=gtk-dialog-error \
        --borders=10 \
        --skip-taskbar \
        --close-on-unfocus \
        --timeout=10
}

key_info() {
    local id=$1
    local info=$(gpg --list-keys --fingerprint --with-sig-check --with-colons $id)

    echo "<big><tt>"
    echo "<b>Label:</b>       Personal Key ($id)"     # ToDo: add label on config/settings

    local uid=$(echo "$info" | grep -E '^uid:[^r]:' | head -1 | cut -d: -f10 | tr '<>' '()')
    echo "<b>Identity:</b>    $uid"

    local fpr=$(echo "$info" | grep '^fpr:' | head -1 | cut -d: -f10 | sed 's/..../\0 /g')
    echo "<b>Fingerprint:</b> $fpr"


    local time1=$(echo "$info" | grep -E '^(pub|sub):[^r]:' | head -1 | cut -d: -f6)
    local time1=$(echo "$info" | grep -E '^(pub|sub):[^r]:' | head -1 | cut -d: -f7)
    local creation=$(date -d @$time1 +%F)
    local expiration='never'
    [[ -n $time2 ]] && expiration=$(date -d @$time2 +%F)
    echo "<b>Creation:</b>    $creation"
    echo "<b>Expiration:</b>  $expiration"
    echo "</tt></big>"
}
