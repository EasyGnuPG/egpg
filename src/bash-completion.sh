# completion file for bash
# for help see:
#  - http://tldp.org/LDP/abs/html/tabexpansion.html
#  - https://www.debian-administration.org/article/317/An_introduction_to_bash_completion_part_2
#  - https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html

_egpg_complete_dir() {
    local default="$1"
    local pattern="${cur:-$default}"
    COMPREPLY=()
    pattern="${pattern%/}*"
    for dir in $pattern ; do
        [[ -d "$dir" ]] || continue
        COMPREPLY+=( "$dir" )
    done
    [[ -z "${COMPREPLY[@]}" ]] && COMPREPLY+=("$default")
}

_egpg()
{
    COMPREPLY=()
    local cur=$2
    if [[ $COMP_CWORD == 1 ]]; then
        local commands="init migrate info seal open sign verify set key contact gpg help version"
        COMPREPLY=( $(compgen -W "$commands" -- $cur) )
        return
    fi

    local cmd="${COMP_WORDS[1]}"
    local last=$3
    case $cmd in
        init)
            _egpg_complete_dir ~/.egpg
            ;;
        migrate)
            if [[ $last == "-d" || $last == "--homedir" ]]; then
                _egpg_complete_dir ~/.gnupg
            else
                COMPREPLY=( $(compgen -W "-d --homedir" -- $cur) )
            fi
            ;;
        seal)
            if [[ $COMP_CWORD == 2 ]]; then
                COMPREPLY=( $(compgen -f -- $cur) )
            else
                local contacts=$(egpg contact ls | grep '^uid: ' | cut -d"<" -f2 | cut -d">" -f1)
                COMPREPLY=( $(compgen -W "$contacts" -- $cur) )
            fi
            ;;
        open)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -X '!*.sealed' -- $cur) )
            ;;
        sign)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -X '*.signature' -- $cur) )
            ;;
        verify)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -X '!*.signature' -- $cur) )
            ;;
        key)
            if [[ $COMP_CWORD == 2 ]]; then
                local commands="generate list delete export import fetch renew expiration revcert revoke pass help"
                COMPREPLY=( $(compgen -W "$commands" -- $cur) )
            else
                _egpg_key
            fi
            ;;
        contact)
            if [[ $COMP_CWORD == 2 ]]; then
                local commands="list show find delete export import fetch fetch-uri search receive pull certify uncertify trust help"
                COMPREPLY=( $(compgen -W "$commands" -- $cur) )
            else
                _egpg_contact
            fi
            ;;
    esac
}

_egpg_key() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local last="${COMP_WORDS[$COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[2]}"
    case $cmd in
        ls|list|show)
            if [[ $last == $cmd ]]; then
                COMPREPLY=( $(compgen -W "-r --raw -c --colons -a --all" -- $cur) )
            fi
            ;;
        gen|generate)
            if [[ $last != "-n" && $last != "--no-passphrase" ]]; then
                COMPREPLY=( $(compgen -W "-n --no-passphrase" -- $cur) )
            fi
            ;;
        rm|del|delete)
            if [[ $last == $cmd ]]; then
                local key_ids=$(egpg key ls -a | grep '^id: ' | cut -d' ' -f2)
                COMPREPLY=( $(compgen -W "$key_ids" -- $cur) )
            fi
            ;;
        exp|export)
            if [[ $last == $cmd ]]; then
                local key_ids=$(egpg key ls -a | grep '^id: ' | cut -d' ' -f2)
                COMPREPLY=( $(compgen -W "$key_ids" -- $cur) )
            fi
            ;;
        imp|import)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -- $cur) )
            ;;
        rev|revoke)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -X '!*.revoke' -- $cur) )
            ;;
        renew|expiration)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -W "$(date -d'1 year' +%F)" -- $cur) )
            ;;
        fetch)
            if [[ $last == "-d" || $last == "--homedir" ]]; then
                _egpg_complete_dir ~/.gnupg
            elif [[ $last == "-k" || $last == "--key-id" ]]; then
                local homedir=~/.gnupg
                if [[ "${COMP_WORDS[$COMP_CWORD-3]}" == "-d" || "${COMP_WORDS[$COMP_CWORD-3]}" == "--homedir" ]]; then
                    homedir="${COMP_WORDS[$COMP_CWORD-2]}"
                fi
                local secret_keys=$(gpg --homedir "$homedir" -K --with-colons | grep "^sec:" | cut -d: -f5)
                COMPREPLY=( $(compgen -W "$secret_keys" -- $cur) )
            else
                COMPREPLY=( $(compgen -W "-d --homedir -k --key-id" -- $cur) )
            fi
            ;;
    esac
}

_egpg_contact() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local last="${COMP_WORDS[$COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[2]}"
    case $cmd in
        ls|list|show|find)
            ;;
    esac
}

complete -o filenames -F _egpg egpg egpg.sh
