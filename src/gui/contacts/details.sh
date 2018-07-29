gui_contacts_details(){
    # display details of a single key with edit options
    # basic dummy contact details
    # TODO: add delete export etc. buttons

    [[ -z "$@" ]] \
    && message error "<tt>Please select a contact first.<tt>" \
    || cert_status="Uncertify"; yad --text="<big><tt> \
                                            $(call cmd_contact_list "$1" \
                                            | pango_raw \
                                            | sed 's/[^ ]*/\<b\>&\<\/b\>/') \
                                            </tt></big>" \
           --selectable-labels \
           --borders=10 \
           --form \
           --columns=4 \
           --field="Delete":FBTN "bash -c 'gui contacts_delete'" \
           --field="$cert_status":FBTN "bash -c 'gui contacts_certify'" \
           --field="Trust":FBTN "bash -c 'gui contacts_trust'" \
           --field="Export":FBTN "bash -c 'gui contacts_export'" \
           --button=gtk-quit
}