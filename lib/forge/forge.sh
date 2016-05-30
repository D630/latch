#!/usr/bin/env sh

_fadd ()
{
        printf '%s|%s|%s\n' "$b" "$u" "$c"
}

fadd ()
{
        local \
                _r \
                u="${1%.git}" \
                b="${2%/}" \
                c="${3:-'<>'}";

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
                _fadd > ./LINFO;
                gcommit "forge latchkey ${b}"
                msg "latch/forge/fadd: Forging latchkey ring ..."
                gcheckout "master"
                _fadd >> ./LINFO;
                command sort -u -o ./LINFO ./LINFO
                gcommit "forge latchkey ring"
        fi
}

fcommit ()
{
        if
                ! gcheck "isGit"
        then
                die "latch/forge/fcommit/error: latchkey ring not forged"
        fi

        local \
                _b \
                _c \
                _u \
                b;

        b="$(gget "currentBranch")"

        if
                [ "$b" = "master" ]
        then
                msg "latch/forge/fcommit: Forging latchkey ring ..."
                gcommit "forge latchkey ring" || :;
        else
                if
                        gcheck "isChanged" "./LINFO"
                then
                        msg "latch/forge/fcommit: Forging latchkey '${b}' ..."
                        gcommit "forge latchkey '${b}'" || :;
                else
                        IFS='|' read -r _b _u _c < "./LINFO" || :;
                        msg "latch/forge/fcommit: Forging latchkey '${b}' ..."
                        gcommit "forge latchkey '${b}'" || :;
                        gcheckout "master"
                        command ed -s "./LINFO" <<S
1,\$ s/^$(echo "${b}|[^|]*|[^|]*" | command sed -e 's|/|\\/|g')\$/$(echo "${_b}|${_u}|${_c}" | command sed -e 's|/|\\/|g')/
w
S
                        msg "latch/forge/fcommit: Forging latchkey ring ..."
                        gcommit "forge latchkey ring" || :;
                        msg "latch/forge/fcommit: Switching back ..."
                        gcheckout "$b"
                fi
        fi
}

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
                command ed -s "./LINFO" <<S
g/^$(echo "${b}|[^|]*|[^|]*" | command sed -e 's|/|\\/|g')\$/d
w
S
                gcommit "forge latchkey ring"
        else
                die "latch/forge/fremove/error: latchkey has not been hammered: '${b}'"
        fi
}

fring ()
if
        gcheck "isGit"
then
        die "latch/forge/fring/error: latchkey ring already hammered"
else
        msg "latch/forge/fring: Hammering latchkey ring ..."
        ginit "hammer latchkey ring"
        msg "latch/forge/fring: Forging latchkey ring ..."
        printf '%s' "" > LINFO;
        gcommit "forge latchkey ring"
fi

# vim: set ts=8 sw=8 tw=0 et :
