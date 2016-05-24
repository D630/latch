#!/usr/bin/env sh

_fadd ()
{
        printf "'%s/m' '%s'\n" "$b" "${b}.git"
        printf "'%s/u' '%s'\n" "$b" "$u"
}

fadd ()
{
        local \
                _r \
                u="${1%.git}" \
                b="${2%/}";
        b="${b#/}"
        u="${u}.git"

        if
                ! gcheck "isGit"
        then
                die "latch/forge/fadd/error: latchkey ring not forged"
        fi

        if
                ! gcheck "isValidUri" "$u"
        then
                if
                        gcheck "isValidUri" "${u%.git}"
                then
                        u="${u%.git}"
                else
                        die "latch/forge/fadd/error: URI is not valid: ${u}"
                fi
        fi

        if
                ! gcheck "isValidBranchFormat" "$b"
        then
                die "latch/forge/fadd/error: latchkey name is not valid: '${b}'"
        fi

        if
                gcheck "isBranch" "$b"
        then
                die "latch/forge/fadd/error: latchkey already hammered: '${b}'"
        else
                msg "latch/forge/fadd: Hammering latchkey '${b}' ..."
                gbranch "add" "$b" "hammer latchkey ${b}"
                msg "latch/forge/fadd: Forging latchkey '${b}' ..."
                skel "latchkey"
                _fadd > LREMOTE;
                gcommit "forge latchkey ${b}"
                msg "latch/forge/fadd: Forging latchkey ring ..."
                gcheckout "master"
                _fadd >> LREMOTE;
                gcommit "forge latchkey ring"
        fi
}

# vim: set ts=8 sw=8 tw=0 et :
