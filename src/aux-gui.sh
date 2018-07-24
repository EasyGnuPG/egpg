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
