#!/usr/bin/env sh

fremove () {

        local  \
                _r \
                b="${1%/}";
        b="${b#/}"

        if
                ! gcheck "isGit"
        then
                die "latch/forge/fremove/error: latchkey ring not forged"
        fi

        if
                gcheck "isBranch" "$b"
        then
                gcheckout "$b"
                gclean
                msg "latch/forge/fremove: Destroying latchkey '${b}' ..."
                gbranch "delete" "$b"
                msg "latch/forge/fremove: Forging latchkey ring ..."
                command ed -s "./LREMOTE" <<S
g/^$(echo "'${b}/[mu]' " | command sed -e 's|/|\\/|g')/d
w
S
                gcommit "forge latchkey ring"
        else
                die "latch/forge/fremove/error: latchkey has not been hammered: '${b}'"
        fi
}

# vim: set ts=8 sw=8 tw=0 et :
