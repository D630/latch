#!/usr/bin/env sh

pconfigure ()
{
        if
                IFS= read -r myContext < "${myKeyRing}/LCONTEXT"
        then
                msg "latch/pkg/pconfigure: myContext -> ${myContext}"
        else
                die "latch/pkg/pconfigure/error: myContext -?"
        fi
        readonly myContext

        context "$myContext"

        msg "latch/pkg/pconfigure: myUid -> ${myUid}"

        if
                test -r "$myXstowConfig"
        then
                msg "latch/pkg/pconfigure: myXstowConfig -> ${myXstowConfig}"
        else
                die "latch/pkg/pconfigure/error: myXstowConfig -?"
        fi

        if
                test -d "$STOW_DIR"
        then
                msg "latch/pkg/pconfigure: STOW_DIR -> ${STOW_DIR}"
        else
                die "latch/pkg/pconfigure/error: STOW_DIR -? ${STOW_DIR}"
        fi

        if
                test -d "$STOW_TARGET"
        then
                msg "latch/pkg/pconfigure: STOW_TARGET -> ${STOW_TARGET}"
        else
                die "latch/pkg/pconfigure/error: STOW_TARGET -? ${STOW_TARGET}"
        fi

        PKG_NAME="$KEY_NAME" \
        PKG_VERSION="${DISTDIR_DESC}/${KEY_DESC}" \
        DESTDIR="${STOW_DIR}/${PKG_NAME}"

        msg "latch/pkg/pconfigure: PKG_NAME -> ${PKG_NAME}"
        msg "latch/pkg/pconfigure: DESTDIR -> ${DESTDIR}"
        msg "latch/pkg/pconfigure: PKG_VERSION -> ${PKG_VERSION}"

        command mkdir -p "$DESTDIR"

        eval "$(
                cd -- "$DESTDIR"

                export \
                        GIT_DIR="${DESTDIR}/.git" \
                        GIT_WORK_TREE="$DESTDIR";

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
                        exit
                fi

                echo "currentBranch=$(
                        gget "currentBranch" 2>/dev/null
                )"

                echo arePacked="$(
                        gget "branchCnt" 2>/dev/null
                )"

        )"

        if
                test -r "$myPkgList"
        then
                stowedIs="$(
                        command grep -e "^${PKG_NAME}|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|1$" "$myPkgList" \
                        | {
                                IFS='|' read -r _ d k _ _ || :;
                                echo "${d:+${d}/}${k}"
                        };
                )"
                : "${stowedIs:="<>"}"
        fi

        [ "$PKG_VERSION" = "$stowedIs" ] && isStowed="true";

        msg "latch/pkg/pconfigure: isInitialized -> ${isInitialized}"
        msg "latch/pkg/pconfigure: currentBranch -> ${currentBranch}"
        msg "latch/pkg/pconfigure: arePacked -> ${arePacked}"
        msg "latch/pkg/pconfigure: stowedIs -> ${stowedIs}"
        msg "latch/pkg/pconfigure: isPacked -> ${isPacked}"
        msg "latch/pkg/pconfigure: isStowed -> ${isStowed}"

        readonly \
                DESTDIR \
                PKG_NAME \
                PKG_VERSION \
                STOW_DIR \
                STOW_TARGET \
                arePacked \
                currentBranch \
                isInitialized \
                isPacked \
                isStowed \
                myUid \
                myXstowConfig \
                stowedIs;
}

# vim: set ts=8 sw=8 tw=0 et :
