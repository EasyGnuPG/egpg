workdir_make() {
    [[ -n $WORKDIR ]] && return 0
    unmount_tmpdir() {
	[[ -n $WORKDIR && -d $WORKDIR && -n $DARWIN_RAMDISK_DEV ]] || return 1
	umount "$WORKDIR"
	diskutil quiet eject "$DARWIN_RAMDISK_DEV"
	rm -rf "$WORKDIR"
    }
    trap unmount_tmpdir INT TERM EXIT
    WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/$PROGRAM.XXXXXXXXXXXXX")"
    DARWIN_RAMDISK_DEV="$(hdid -drivekey system-image=yes -nomount 'ram://32768' | cut -d ' ' -f 1)" # 32768 sectors = 16 mb
    [[ -z $DARWIN_RAMDISK_DEV ]] && die "Error: could not create ramdisk."
    newfs_hfs -M 700 "$DARWIN_RAMDISK_DEV" &>/dev/null || die "Error: could not create filesystem on ramdisk."
    mount -t hfs -o noatime -o nobrowse "$DARWIN_RAMDISK_DEV" "$WORKDIR" || die "Error: could not mount filesystem on ramdisk."
}

GETOPT="$(brew --prefix gnu-getopt 2>/dev/null || { which port &>/dev/null && echo /opt/local; } || echo /usr/local)/bin/getopt"
SHRED="srm -f -z"
