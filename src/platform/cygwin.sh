# replaces Cygwin-style filenames with their Windows counterparts
gpg_winpath() {
    local args=("$@")
    # as soon as an argument (from back to front) is no file, it can only be a filename argument if it is preceeded by '-o'
    local could_be_filenames="true"
    local i
    for ((i=${#args[@]}-1; i>=0; i--)); do
	if ( [ $i -gt 0 ] && [ "${args[$i-1]}" = "-o" ] && [ "${args[$i]}" != "-" ] ); then
	    args[$i]="$(cygpath -am "${args[$i]}")"
	elif [ $could_be_filenames = "true" ]; then
	    if [ -e "${args[$i]}" ]; then
		args[$i]="$(cygpath -am "${args[$i]}")"
	    else
		could_be_filenames="false"
	    fi
	fi
    done
    $GPG_ORIG "${args[@]}"
}

if $GPG --help | grep -q 'Home: [A-Z]:[/\\]'; then
    GPG_ORIG="$GPG"
    GPG=gpg_winpath
fi
