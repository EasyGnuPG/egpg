gui_contacts_details(){
    # display details of a single key with edit options
    # basic dummy contact details
    # TODO: add delete export etc. buttons
    [[ -z "$@" ]] || message info "<tt>$(call cmd_contact_list "$1" | pango_raw)</tt>"
}