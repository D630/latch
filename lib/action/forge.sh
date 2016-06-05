#!/usr/bin/env sh

forge__add ()
{
        _fadd ()
        {
                printf '%s|%s|%s\n' "$b" "$u" "$c"
        }

        local \
                _r \
                u="${1%.git}" \
                b="${2%/}" \
                c="${3:-null}";

        b="${b#/}"
        u="${u}.git"

        if
                ! gcheck "isGit"
        then
                die "latchkey ring not forged"
        fi

        if
                ! gcheck "isValidUri" "$u"
        then
                if
                        gcheck "isValidUri" "${u%.git}"
                then
                        u="${u%.git}"
                else
                        die "URI is not valid: '${u}'"
                fi
        fi

        if
                ! gcheck "isValidBranchFormat" "$b"
        then
                die "latchkey name is not valid: '${b}'"
        fi

        if
                gcheck "isBranch" "$b"
        then
                die "latchkey already hammered: '${b}'"
        else
                msg "hammering latchkey '${b}' ..."
                gbranch "add" "$b" "hammer latchkey ${b}"
                msg "forging latchkey '${b}' ..."
                skel "latchkey"
                _fadd > ./LINFO;
                gcommit "forge latchkey ${b}"
                msg "forging latchkey ring ..."
                gcheckout "master"
                _fadd >> ./LINFO;
                command sort -u -o ./LINFO ./LINFO
                gcommit "forge latchkey ring"
        fi
}

forge__commit ()
{
        if
                ! gcheck "isGit"
        then
                die "latchkey ring not forged"
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
                msg "forging latchkey ring ..."
                gcommit "forge latchkey ring" || :;
        else
                if
                        gcheck "isChanged" "${myKeyRing}/LINFO"
                then
                        msg "forging latchkey '${b}' ..."
                        gcommit "forge latchkey '${b}'" || :;
                else
                        IFS='|' read -r _b _u _c < "./LINFO" || :;
                        msg "forging latchkey '${b}' ..."
                        gcommit "forge latchkey '${b}'" || :;
                        gcheckout "master"
                        command ed -s "${myKeyRing}/LINFO" <<S
1,\$ s/^$(echo "${b}|[^|]*|[^|]*" | command sed -e 's|/|\\/|g')\$/$(echo "${_b}|${_u}|${_c}" | command sed -e 's|/|\\/|g')/
w
S
                        msg "forging latchkey ring ..."
                        gcommit "forge latchkey ring" || :;
                        msg "switching back to '${b}' ..."
                        gcheckout "$b"
                fi
        fi
}

forge__remove () {

        local  \
                _r \
                b="${1%/}";
        b="${b#/}"

        if
                ! gcheck "isGit"
        then
                die "latchkey ring not forged"
        fi

        if
                gcheck "isBranch" "$b"
        then
                gcheckout "$b"
                gclean
                msg "destroying latchkey '${b}' ..."
                gbranch "delete" "$b"
                msg "forging latchkey ring ..."
                command ed -s "${myKeyRing}/LINFO" <<S
g/^$(echo "${b}|[^|]*|[^|]*" | command sed -e 's|/|\\/|g')\$/d
w
S
                gcommit "forge latchkey ring"
        else
                die "latchkey has not been hammered: '${b}'"
        fi
}

forge__ring ()
if
        gcheck "isGit"
then
        die "latchkey ring already hammered"
else
        msg "hammering latchkey ring ..."
        ginit "hammer latchkey ring"
        msg "forging latchkey ring ..."
        printf '%s' "" > ./LINFO;
        gcommit "forge latchkey ring"
fi

forge__main ()
{
        import git

        eval set -- "$myArgs"

        c="$1"
        shift 1

        cd -- "$myKeyRing"

        export \
                GIT_DIR="${myKeyRing}/.git" \
                GIT_WORK_TREE="$myKeyRing";

        case "$c" in
        {})
                die "unknown argument: '${c}'"
        ;;
        *)
                "forge__${c}" "$@"
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
