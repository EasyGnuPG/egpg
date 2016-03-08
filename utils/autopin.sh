#!/bin/bash
# Automatically send pin to programs getting a pin via pin-entry. This
# is sometimes necessary.  Mainly, this is used as a pinentry
# replacement for GnuPG when used in combination with an OpenPGP
# smartcard (such as the crypto-stick).  Simply drop this script in
# /usr/local/bin and change your gpg configuration file to point to
# it. Don't forget to add a real PIN, too. 123456 is the default user
# PIN on most OpenPGP smartcards.
# See also: https://github.com/gdestuynder/pinentry-auto

PIN='123456'

echo 'OK Your orders please'
while read reply; do
    case ${reply,,} in
        getpin)
            echo "D $PIN"
            echo OK
            ;;
        bye)
            echo 'OK closing connection'
            break
            ;;
        'getinfo pid')
            echo "D $BASHPID"
            echo OK
            ;;
        *)
            # This generally includes OPTION, SETDESC, SETPROMPT
            # i.e. things we don't care for if we're not displaying
            # a prompt
            echo OK
            ;;
    esac
done

