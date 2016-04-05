# completion file for bash
# for help see:
#  - http://tldp.org/LDP/abs/html/tabexpansion.html
#  - https://www.debian-administration.org/article/317/An_introduction_to_bash_completion_part_2
#  - https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html

_egpg_complete_dir() {
    local default="$1"
    local pattern="${cur:-$default}"
    pattern="${pattern%/}*"
    for dir in $pattern ; do
        [[ -d "$dir" ]] || continue
        COMPREPLY+=("$dir")
    done
    [[ -z "${COMPREPLY[@]}" ]] && COMPREPLY+=("$default")
}

_egpg()
{
    COMPREPLY=()
    local cur=$2
    if [[ $COMP_CWORD == 1 ]]; then
        local commands="init migrate info seal open sign verify set key contact gpg help version"
        COMPREPLY+=($(compgen -W "${commands}" -- $cur))
        return
    fi

    local first="${COMP_WORDS[1]}"
    local last=$3
    case $first in
        init)
            _egpg_complete_dir ~/.egpg
            ;;
        migrate)
            if [[ $last == "-d" || $last == "--homedir" ]]; then
                _egpg_complete_dir ~/.gnupg
            else
                COMPREPLY+=($(compgen -W "-d --homedir" -- $cur))
            fi
            ;;
    esac
}

complete -o filenames -o nospace -F _egpg egpg egpg.sh
