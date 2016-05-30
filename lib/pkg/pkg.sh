#!/usr/bin/env sh

pchop ()
{
        local _b

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        command grep -e "${PKG_NAME}|[^|]*|[^|]*|${myContext}|0" "$myPkgList" \
        | {
                while
                        IFS='|' read -r _ p k _ _ || :;
                do
                        msg "latch/pkg/pchop: Deleting '${p}/${k}' ..."
                        gbranch "delete" "${p}/${k}"
                done;
                punregister "chop-pkg"
        };

        msg "latch/pkg/pchop: Checking out '${stowedIs}' ..."
        gcheckout "$stowedIs"

        msg "latch/pkg/pchop: DONE"
}

pconfigure ()
{
        if
                IFS='|' read -r _ _ myContext < "${myKeyRing}/LINFO" || :;
        then
                msg "latch/pkg/pconfigure: myContext -> ${myContext}"
        else
                die "latch/pkg/pconfigure/error: myContext -?"
        fi
        readonly myContext

        context "$myContext"

        msg "latch/pkg/pconfigure: useId -> ${useId}"
        [ "$currentId" -eq "$useId" ] || die "latch/pkg/pconfigure/error: currentId does not match useId: '${currentId} != ${useId}'";

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

        PKG_NAME="$(
                command sed -e 's|/|::|g' <<IN
${KEY_NAME}
IN
        )" \
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
                        :
                fi

                echo "currentBranch=$(
                        gget "currentBranch" 2>/dev/null
                )"

                echo arePacked="$(
                        gget "branchCnt" 2>/dev/null
                )"

        )"

        if
                test -e "$myPkgList"
        then
                stowedIs="$(
                        command grep -e "^${PKG_NAME}|[^|]*|[^|]*|${myContext}|1$" "$myPkgList" \
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
                myXstowConfig \
                stowedIs \
                useId;
}

pdeinit ()
{
        command rm -rf -- "$DESTDIR"
}

pinit ()
{
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/pinit: Initializing pkg repository ..."
        ginit "init"

        msg "latch/pkg/pinit: DONE"
}

pinstall ()
{
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/pinstall: Branching pkg version ..."
        gbranch "add" "$PKG_VERSION" "add pkg version ${PKG_VERSION}"

        unset -v \
                GIT_DIR \
                GIT_WORK_TREE;

        cd -- "$DISTDIR"

        (
                msg "latch/pkg/pinstall: Invoking src_env() ..."
                src_env
                msg "latch/pkg/pinstall: Invoking src_prepare() ..."
                ( src_prepare )
                msg "latch/pkg/pinstall: Invoking src_build() ..."
                ( src_build )
                msg "latch/pkg/pinstall: Invoking src_check() ..."
                ( src_check )
                msg "latch/pkg/pinstall: Invoking src_install() ..."
                ( src_install )
        )

        # TODO
        gclean
        greset "hard"
        [ "$myContext" = "local" ] || {
                command chown -R "$myIds" \
                        "./.git/HEAD" \
                        "./.git/ORIG_HEAD" \
                        "./.git/index" \
                        "./"*;
        };

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/pinstall: Committing pkg version ..."
        gcommit "commit pkg version ${PKG_VERSION}"

        if
                ! [ "$stowedIs" = "<>" ]
        then
                msg "latch/pkg/pinstall: Checking out again ..."
                gcheckout "$stowedIs"
        fi

        msg "latch/pkg/pinstall: Registering pkg version ..."
        pregister "pkg"

        msg "latch/pkg/pinstall: DONE"

        # TODO
        command chmod -R 755 "${DESTDIR}"/?*
}

__plimit ()
{
        if
                [ "$arePacked" -gt 1 ]
        then
                _l="${_l} chop"
        else
                :
        fi
}

_plimit ()
if
        [ "$stowedIs" != "<>" ]
then
        case "$myPkgAction" in
        purge|stow)
                die "latch/pkg/plimit/error: Current version must be unstowed: '${stowedIs}'"
        esac
        __plimit
else
        :
fi

plimit ()
{
        local _l

        case "${isInitialized}::${isPacked}::${isStowed}" in
        false::*)
                _l="init"
        ;;
        true::false::*)
                _l="install purge"
                _plimit
        ;;
        true::true::false)
                _l="purge remove stow"
                _plimit
        ;;
        true::true::true)
                _l="purge unstow"
                __plimit
        esac

        if
                [ "${_l:-_}" = "_" ]
        then
                die "latch/pkg/plimit/error: Something went wrong, really"
        else
                _l=" ${_l} info "
        fi

        msg "latch/pkg/plimit: {${_l}}"

        case "$_l" in
        *" ${myPkgAction} "*)
                :
        ;;
        *)
                die "latch/pkg/plimit/error: damn, myPkgAction cannot be executed: '${myPkgAction}'"
        esac
}

ppurge ()
{
        msg "latch/pkg/ppurge: Deinitializing '${PKG_VERSION}' ..."
        pdeinit
        msg "latch/pkg/ppurge: Unregistering all pkgs ..."
        punregister any-pkg
        msg "latch/pkg/ppurge: DONE"
}

pregister ()
{
        case "$1" in
        pkg)
                printf '%s|%s|%s|%s|%d\n' \
                        "$PKG_NAME" \
                        "$DISTDIR_DESC" \
                        "$KEY_DESC" \
                        "$myContext" \
                        "0" \
                >> "$myPkgList";
        ;;
        stow)
                command ed -s "$myPkgList" <<S
1,\$ s/^$(echo "\(${PKG_NAME}|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|\)0" | command sed -e 's|/|\\/|g')\$/\11/
w
S
        ;;
        *)
                die "latch/pkg/pregister/error: unknown argument -? ${1}"
        esac

        command chown "$myIds" "$myPkgList"
}

premove ()
{
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/premove: Deleting pkg version '${PKG_VERSION}' ..."
        gbranch "delete" "$PKG_VERSION"

        msg "latch/pkg/premove: Cleaning ..."
        gclean

        if
                ! let "$arePacked - 1 > 0"
        then
                msg "latch/pkg/premove: Deinitializing pkg repository ..."
                pdeinit
        fi

        msg "latch/pkg/premove: Unregistering pkg version ..."
        punregister "pkg"

        msg "latch/pkg/premove: DONE"
}

pstow ()
{
        import stow

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/pstow: Checking out '${PKG_VERSION}'..."
        gcheckout "$PKG_VERSION"

        msg "latch/pkg/pstow: Cleaning ..."
        gclean

        unset -v \
                GIT_DIR \
                GIT_WORK_TREE;

        msg "latch/pkg/pstow: Invoking stow_prae() ..."
        (
                stow_prae
        )

        msg "latch/pkg/pstow: Stowing ${PKG_VERSION} ..."
        (
                cd ..
                sstow "${PKG_NAME##*/}"
        )

        msg "latch/pkg/pstow: Invoking stow_post() ..."
        (
                stow_post
        )

        msg "latch/pkg/pstow: Registering stowed version ..."
        pregister "stow"

        msg "latch/pkg/pstow: DONE"
}

punregister ()
{
        case "$1" in
        any-pkg)
                command ed -s "$myPkgList" <<S
g/^"${PKG_NAME}|[^|]*|[^|]*|${myContext}|[01]"\$/d
w
S
        ;;
        chop-pkg)
                command ed -s "$myPkgList" <<S
g/^"${PKG_NAME}|[^|]*|[^|]*|${myContext}|0"\$/d
w
S
        ;;
        pkg)
                command ed -s "$myPkgList" <<S
g/^$(echo "${PKG_NAME}|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|0" | command sed -e 's|/|\\/|g')\$/d
w
S
        ;;
        stow)
                command ed -s "$myPkgList" <<S
1,\$ s/^$(echo "\(${PKG_NAME}|[^|]*|[^|]*|${myContext}|\)1" | command sed -e 's|/|\\/|g')$/\10/
w
S
        ;;
        *)
                die "latch/pkg/punregister/error: unknown argument -? ${1}"
        esac

        command chown "$myIds" "$myPkgList"
}

punstow ()
{
        import stow

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/punstow: Checking out '${PKG_VERSION}' ..."
        gcheckout "$PKG_VERSION"

        unset -v \
                GIT_DIR \
                GIT_WORK_TREE;

        msg "latch/pkg/punstow: Invoking unstow_prae() ..."
        (
                unstow_prae
        )

        msg "latch/pkg/punstow: Unstowing ${PKG_VERSION} ..."
        (
                cd ..
                sunstow "${PKG_NAME##*/}"
        )

        msg "latch/pkg/punstow: Invoking unstow_post() ..."
        (
                unstow_post
        )

        msg "latch/pkg/punstow: Unregistering stowed version ..."
        punregister "stow"

        msg "latch/pkg/punstow: DONE"
}

# vim: set ts=8 sw=8 tw=0 et :
