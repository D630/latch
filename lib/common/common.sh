#!/usr/bin/env sh

action ()
{
        . "${myRoot}/lib/action/${1}.sh" && "${1}__main";
}

context ()
{
        if
                test -e "${myRoot}/etc/context/${1}.sh"
        then
                . "${myRoot}/etc/context/${1}.sh"
        else
                die "context file does not exist: '${myRoot}/etc/context/${1}.sh'"
        fi

        "${1}_context"

        msg "useIds := ${useIds}"
        [ "$currentId" -eq "${useIds%:*}" ] ||
            die "currentId does not match useId: '${currentId} <> ${useIds}'";

        msg "myXstowConfig := ${myXstowConfig}"
        if
                ! test -e "$myXstowConfig"
        then
                die "myXstowConfig does not exist: '$myXstowConfig'"
        fi

        msg "STOW_DIR := ${STOW_DIR}"
        if
                ! test -d "$STOW_DIR"
        then
                die "STOW_DIR is not a directory: '${STOW_DIR}'"
        fi

        msg "STOW_TARGET := ${STOW_TARGET}"
        if
                ! test -d "$STOW_TARGET"
        then
                die "STOW_TARGET is not a directory: '${STOW_TARGET}'"
        fi

        readonly \
                STOW_DIR \
                STOW_TARGET \
                myXstowConfig \
                useIds;
}

die ()
{
        printf "latch/${myAction:-main}/error# %s\n" "$*" 1>&2;
        exit 1
}

env ()
{
        local _i _g

        currentId="$(idu)"
        msg "currentId := ${currentId}"

        myHostname="$(command hostname -s)"
        msg "myHostname := ${myHostname}"

        readonly \
                currentId \
                myHostname;

        . "${myRoot}/etc/env/${myHostname}.sh"
        msg "myUser := ${myUser}"
        msg "myIds := ${myIds}"

        IFS=':' read -r _i _g <<IN
${myIds}
IN
        if
                [ -n "$_i" -a -n "$_g" ]
        then
                readonly \
                        myIds \
                        myUser;
        else
                die "myIds is not valid: '${myIds}'"
        fi
}

idu ()
{
        command id -u
}

import ()
{
        local \
                __i \
                _i;

        for _i
        do
                if
                        test -d "${myRoot}/lib/${_i}/"
                then
                        for __i in "${myRoot}/lib/${_i}/"?*.sh
                        do
                                . "$__i"
                        done
                else
                        . "${myRoot}/lib/${_i}.sh"
                fi
        done
}

let ()
{
        IFS=, command eval test '$(( ${*} ))' -ne '0'
}

linfo ()
(
        cd -- "$myKeyRing"

        export \
                GIT_DIR="${myKeyRing}/.git" \
                GIT_WORK_TREE="$myKeyRing";

        if
                command git grep \
                        -G \
                        --color=never \
                        -h \
                        -e "^${KEY_NAME}|[^|]*|[^|]*\$" \
                        "${1}" \
                        -- ./LINFO 2>/dev/null;
        then
                gget "description" "${1}" 2>/dev/null;
        else
                die "could not describe '${1}' in '${myKeyRing}', when using KEY_NAME '${KEY_NAME}'"
        fi
)

minfo ()
(
        cd -- "${myMirror}/${KEY_NAME}.git"

        export GIT_DIR="${myMirror}/${KEY_NAME}.git"

        if
                ! gget "description" "$1" 2>/dev/null;
        then
                die "could not describe '${1}' in '${myMirror}/${KEY_NAME}.git'"
        fi
)

msg ()
{
        printf "latch/${myAction:-main}# %s\n" "$*" 1>&2;
}

pname ()
{
        command sed -e 's|/|::|g' <<IN
${1}
IN
}

register ()
{
        case "$1" in
        pkg)
                printf '%s|%d|%s|%s|%s|%d\n' \
                        "$PKG_NAME" \
                        "$(command date +%s)" \
                        "$DISTDIR_DESC" \
                        "$KEY_DESC" \
                        "$myContext" \
                        "0" \
                >> "$myPkgList";
        ;;
        stow)
                command ed -s "$myPkgList" <<S
1,\$ s/^$(echo "\(${PKG_NAME}|[0-9]*|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|\)0" | command sed -e 's|/|\\/|g')\$/\11/
w
S
        ;;
        *)
                die "unknown argument: '${1}'"
        esac

        command chown "$myIds" "$myPkgList"
}

rights ()
{
        # TODO
        command find "$1" -type d -exec chmod 2775 {} + &
        command find "$1" ! -type d -exec chmod 0644 {} + &
        command chown -R "$useIds" "$1" &
        wait
}

skel ()
{
        local _f

        for _f in "${myRoot}/share/skel/${1}/"?*
        do
                test -e "$_f" && command cp -- "$_f" "${2:-.}";
        done
}

sinfo ()
{
        command mkdir -p "${STOW_DIR}/${PKG_NAME}"

        eval "$(
                cd -- "${STOW_DIR}/${PKG_NAME}"

                export \
                        GIT_DIR="${STOW_DIR}/${PKG_NAME}/.git" \
                        GIT_WORK_TREE="${STOW_DIR}/${PKG_NAME}";

                if
                        gcheck "isGit" 1>/dev/null 2>&1;
                then
                        echo "isInitialized=true"
                else
                        exit
                fi

                if
                        gcheck "isBranch" "$PKG_VERSION" 1>/dev/null 2>&1;
                then
                        echo "isPacked=true"
                else
                        :
                fi

                echo "stowedIs=$(
                        gget "stowedBranch"
                )"

                echo "currentBranch=$(
                        gget "currentBranch" 2>/dev/null
                )"

                echo arePacked="$(
                        gget "branchCnt" 2>/dev/null
                )"
        )"

        [ "$PKG_VERSION" = "$stowedIs" ] && isStowed="true";

        msg "isInitialized := ${isInitialized}"
        msg "currentBranch := ${currentBranch}"
        msg "arePacked := ${arePacked}"
        msg "stowedIs := ${stowedIs}"
        msg "isPacked := ${isPacked}"
        msg "isStowed := ${isStowed}"

        readonly \
                arePacked \
                currentBranch \
                isInitialized \
                isPacked \
                isStowed \
                stowedIs;
}

unregister ()
{
        case "$1" in
        any-pkg)
                command ed -s "$myPkgList" <<S
g/^${PKG_NAME}|[0-9]*|[^|]*|[^|]*|${myContext}|[01]\$/d
w
S
        ;;
        chop-pkg)
                command ed -s "$myPkgList" <<S
g/^${PKG_NAME}|[0-9]*|[^|]*|[^|]*|${myContext}|0\$/d
w
S
        ;;
        pkg)
                command ed -s "$myPkgList" <<S
g/^$(echo "${PKG_NAME}|[0-9]*|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|0" | command sed -e 's|/|\\/|g')\$/d
w
S
        ;;
        stow)
                command ed -s "$myPkgList" <<S
1,\$ s/^$(echo "\(${PKG_NAME}|[0-9]*|[^|]*|[^|]*|${myContext}|\)1" | command sed -e 's|/|\\/|g')$/\10/
w
S
        ;;
        *)
                die "unknown argument: '${1}'"
        esac

        command chown "$myIds" "$myPkgList"
}

# vim: set ts=8 sw=8 tw=0 et :
