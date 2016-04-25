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
        local commands="init migrate info seal open sign verify set default key contact gpg help version"
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
                COMPREPLY=( $(compgen -W "--homedir" -- $cur) )
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
                local commands="generate list delete backup restore fetch renew expiration revcert revoke pass split join recover help"
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
        set)
            if [[ $last == $cmd ]]; then
                COMPREPLY=( $(compgen -W "debug share dongle" -- $cur) )
            elif [[ $last == "debug" || $last == "share" ]]; then
                COMPREPLY=( $(compgen -W "yes no" -- $cur) )
            elif [[ $last == "dongle" ]]; then
                COMPREPLY=( $(compgen -d -- $cur) )
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
                COMPREPLY=( $(compgen -W "--raw --colons --all" -- $cur) )
            fi
            ;;
        gen|generate)
            if [[ $last != "-n" && $last != "--no-passphrase" ]]; then
                COMPREPLY=( $(compgen -W "--no-passphrase" -- $cur) )
            fi
            ;;
        rm|del|delete)
            if [[ $last == $cmd ]]; then
                local key_ids=$(egpg key ls -a | grep '^id: ' | cut -d' ' -f2)
                COMPREPLY=( $(compgen -W "$key_ids" -- $cur) )
            fi
            ;;
        backup)
            if [[ $last == $cmd ]]; then
                local key_ids=$(egpg key ls -a | grep '^id: ' | cut -d' ' -f2)
                COMPREPLY=( $(compgen -W "$key_ids --qrencode" -- $cur) )
            elif [[ $last != "--qrencode" ]]; then
                COMPREPLY=( $(compgen -W "--qrencode" -- $cur) )
            fi
            ;;
        restore)
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
                COMPREPLY=( $(compgen -W "--homedir --key-id" -- $cur) )
            fi
            ;;
        split)
            if [[ $last == "-d" || $last == "--dongle" || $last == "-b" || $last == "--backup" ]]; then
                COMPREPLY=( $(compgen -d -- $cur) )
            else
                COMPREPLY=( $(compgen -W "--dongle --backup" -- $cur) )
            fi
            ;;
        recover)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -X '!*.key.[0-9][0-9][0-9]' -- $cur) )
            ;;
    esac
}

_egpg_complete_contacts() {
    local contacts=$(egpg contact ls | grep '^uid: ' | cut -d"<" -f2 | cut -d">" -f1)
    COMPREPLY=( $(compgen -W "$contacts $@" -- $cur) )
}

_egpg_contact() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local last="${COMP_WORDS[$COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[2]}"
    case $cmd in
        ls|list|show|find)
            _egpg_complete_contacts
            ;;
        rm|del|delete)
            _egpg_complete_contacts
            ;;
        exp|export)
            if [[ $last == "-o" || $last == "--output" ]]; then
                COMPREPLY=( $(compgen -f -- $cur) )
            else
                _egpg_complete_contacts "--output"
            fi
            ;;
        imp|import|add)
            [[ $last == $cmd ]] && COMPREPLY=( $(compgen -f -- $cur) )
            ;;
        fetch)
            if [[ $last == $cmd ]]; then
                COMPREPLY=( $(compgen -W "--homedir" -- $cur) )
            elif [[ $last == "-d" || $last == "--homedir" ]]; then
                _egpg_complete_dir ~/.gnupg
            else
                local homedir=~/.gnupg
                if [[ "${COMP_WORDS[3]}" == "--homedir" ]]; then
                    homedir="${COMP_WORDS[4]}"
                fi
                local keys=$(gpg2 --homedir "$homedir" -k --with-colons | grep "^uid:" | cut -d: -f10 | cut -d"<" -f2 | cut -d">" -f1)
                COMPREPLY=( $(compgen -W "$keys" -- $cur) )
            fi
            ;;
        certify)
            if [[ $last == $cmd ]]; then
                _egpg_complete_contacts
            elif [[ $last == "-l" || $last == "--level" ]]; then
                COMPREPLY=( $(compgen -W "unknown onfaith casual extensive" -- $cur) )
            elif [[ $last == "-t" || $last == "--time" ]]; then
                COMPREPLY=( $(compgen -W "1y" -- $cur) )
            else
                COMPREPLY=( $(compgen -W "--publish --level --time" -- $cur) )
            fi
            ;;
        uncertify)
            [[ $last == $cmd ]] && _egpg_complete_contacts
            ;;
        trust)
            if [[ $last == $cmd ]]; then
                _egpg_complete_contacts
            elif [[ $last == "-l" || $last == "--level" ]]; then
                COMPREPLY=( $(compgen -W "full marginal none unknown" -- $cur) )
            elif [[ "${COMP_WORDS[$COMP_CWORD-2]}" != "--level" ]]; then
                COMPREPLY=( $(compgen -W "--level" -- $cur) )
            fi
            ;;
    esac
}

complete -o filenames -F _egpg egpg egpg.sh src/egpg.sh
