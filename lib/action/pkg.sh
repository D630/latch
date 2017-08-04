#!/usr/bin/env sh

pkg__build ()
(
        # readonly \
        #         DESTDIR="${myBuild}/${PKG_NAME}" \
        #         DISTDIR="${myCheckout}/${PKG_NAME}" \
        #         KEYDIR="${myKey}/${PKG_NAME}";

        readonly \
                DESTDIR="$myBuild/$KEY_NAME" \
                DISTDIR="$myCheckout/$KEY_NAME" \
                KEYDIR="$myKey/$KEY_NAME";

        msg "DISTDIR := ${DISTDIR}"
        msg "DESTDIR := ${DESTDIR}"
        msg "KEYDIR := ${KEYDIR}"

        command rm -fr "$DESTDIR" "$DISTDIR" "$KEYDIR"
        command mkdir -p "$DESTDIR"

        gclone "${myMirror}/${KEY_NAME}.git" "$DISTDIR";
        gclone "$myKeyRing" "$KEYDIR";

        cd -- "$KEYDIR"
        export \
                GIT_DIR="${KEYDIR}/.git" \
                GIT_WORK_TREE="$KEYDIR";
        gcheckout "$KEY_DESC"

        . "${KEYDIR}/LBUILD"

        cd -- "$DISTDIR"
        export \
                GIT_DIR="${DISTDIR}/.git" \
                GIT_WORK_TREE="$DISTDIR";
        gcheckout "$DISTDIR_DESC"
        gsubmodule "update"

        (
                msg "invoking src_env() ..."
                src_env
                msg "invoking src_prepare() ..."
                ( src_prepare )
                msg "invoking src_build() ..."
                ( src_build )
                msg "invoking src_check() ..."
                ( src_check )
                msg "invoking src_install() ..."
                ( src_install )
        )

        cd -- "$DESTDIR"

        command cp -fp -- "${KEYDIR}/LBUILD" "${DESTDIR}/.LBUILD"
        echo "$PKG_VERSION" > "${DESTDIR}/.PKG_VERSION";
        command find -H "${DESTDIR}/." \
                \( ! -name . -a ! -name .LFILES -a ! -name .PKG_VERSION \) \
                -prune \
                > "${DESTDIR}/.LFILES";
)

pkg__chop ()
(
        local _b

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        command grep -e "^${PKG_NAME}|[0-9]*|[^|]*|[^|]*|${myContext}|0$" "$myPkgList" \
        | {
                while
                        IFS='|' read -r _ _ p k _ _;
                do
                        msg "deleting '${p}/${k}' ..."
                        gbranch "delete" "${p}/${k}"
                done;
                unregister "chop-pkg"
        };

        msg "checking out '${stowedIs}' ..."
        gcheckout "$stowedIs"
)

pkg__init ()
(
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "initializing pkg repository ..."
        ginit "init"

        msg "setting rights ..."
        rights "$DESTDIR"
)

pkg__install ()
(
        __cd_gitdir ()
        {
                cd -- "${STOW_DIR}/${PKG_NAME}"

                export \
                        GIT_DIR="${STOW_DIR}/${PKG_NAME}/.git" \
                        GIT_WORK_TREE="${STOW_DIR}/${PKG_NAME}";
        }

        __trap ()
        {
                __cd_gitdir
                msg "Rolling back ..."
                msg "deleting pkg version '${PKG_VERSION}' ..."
                gbranch "delete" "$PKG_VERSION"

                msg "cleaning ..."
                gclean
        }

        trap 'p=$? ; __trap ; exit $p' 1 2 3 6 9 15 EXIT

        # readonly DESTDIR="${myBuild}/${PKG_NAME}"
        readonly DESTDIR="$myBuild/$KEY_NAME"
        msg "DESTDIR := ${DESTDIR}"

        __cd_gitdir

        msg "branching pkg version '${PKG_VERSION}'..."
        gbranch "add" "$PKG_VERSION" "add pkg version ${PKG_VERSION}"

        msg "comparing build pkg version with '${PKG_VERSION}' ..."
        local p
        IFS= read -r p < "${DESTDIR}/.PKG_VERSION";
        if
                ! [ "$p" = "$PKG_VERSION" ]
        then
                die "the currently build package version is not the one you are going to install: '${p} <> ${PKG_VERSION}'"
        fi

        msg "moving pkg files to '${STOW_DIR}/${PKG_NAME}' ..."
        #command cp -fpR -- "${DESTDIR}"/. "${STOW_DIR}/${PKG_NAME}"
        local f
        while
                IFS= read -r f
        do
                if
                        test -d "$f"
                then
                        command cp -fpR "${f}/." "${STOW_DIR}/${PKG_NAME}/${f##*/}"
                elif
                        test -f "$f"
                then
                        command cp -fp "$f" "${STOW_DIR}/${PKG_NAME}/${f##*/}"
                else
                        die "cannot stat file: '${f}'"
                fi
        done < "${DESTDIR}/.LFILES"

        trap - 1 2 3 6 9 15 EXIT

        msg "setting rights ..."
        rights "$DESTDIR"

        msg "committing pkg version '${PKG_VERSION}' ..."
        gcommit "commit pkg version ${PKG_VERSION}"

        if
                ! [ "$stowedIs" = "null" ]
        then
                msg "checking out '${stowedIs}' again ..."
                gcheckout "$stowedIs"
                msg "setting rights ..."
                rights "$DESTDIR"
        fi

        msg "registering pkg version '${PKG_VERSION}' ..."
        register "pkg"
)

pkg__purge ()
{
        msg "deinitializing pkg repo '${DESTDIR}' ..."
        command rm -rf -- "$DESTDIR"

        msg "unnregistering all pkgs ..."
        unregister "any-pkg"
}

pkg__remove ()
(
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "deleting pkg version '${PKG_VERSION}' ..."
        gbranch "delete" "$PKG_VERSION"

        msg "cleaning ..."
        gclean

        if
                let "$arePacked - 1 > 0"
        then
                msg "setting rights ..."
                rights "$DESTDIR"
                msg "unregistering pkg version '${PKG_VERSION}' ..."
                unregister "pkg"
        else
                pkg__purge
        fi
)

pkg__main ()
{
        src_build       () { return 0 ; }
        src_check       () { return 0 ; }
        src_env         () { return 0 ; }
        src_install     () { return 0 ; }
        src_prepare     () { return 0 ; }

        DESTDIR= \
        DISTDIR= \
        DISTDIR_DESC= \
        KEYDIR= \
        KEY_DESC= \
        KEY_NAME= \
        PKG_NAME= \
        PKG_VERSION= \
        STOW_DIR= \
        STOW_TARGET= \
        arePacked=0 \
        currentBranch="null" \
        currentId= \
        isInitialized="false" \
        isPacked="false" \
        isStowed="false" \
        myContext= \
        myHostname= \
        myIds= \
        myPkgAction= \
        myUser= \
        myXstowConfig= \
        stowedIs="null" \
        useIds=;

        import git pkg

        eval set -- "$myArgs"

        readonly myPkgAction="$1"
        shift 1
        msg "myPkgAction := ${myPkgAction}"

        msg "myPkgList := ${myPkgList}"
        env
        msg "KEY_NAME := ${KEY_NAME:=$1}"

        eval "$(
                linfo "${3:-$KEY_NAME}" \
                | {
                        IFS='|' read -r _ _ myContext;
                        IFS= read -r KEY_DESC;
                        echo myContext="$myContext" KEY_DESC="$KEY_DESC"
                }
        )"
        msg "KEY_DESC := ${KEY_DESC:?}"

        DISTDIR_DESC="$(minfo "${2:-HEAD}")"
        msg "DISTDIR_DESC := ${DISTDIR_DESC:?}"

        readonly \
                DISTDIR_DESC \
                KEY_DESC \
                KEY_NAME \
                myContext \
                myPkgAction;

        if
                test -n "$myContext"
        then
                msg "myContext := ${myContext}"
                context "$myContext"
        else
                die "myContext is null"
        fi

        PKG_NAME="$(pname "$KEY_NAME")" \
        PKG_VERSION="${DISTDIR_DESC}/${KEY_DESC}"

        msg "PKG_NAME := ${PKG_NAME}"
        msg "PKG_VERSION := ${PKG_VERSION}"

        readonly \
                PKG_NAME \
                PKG_VERSION;

        case "$myPkgAction" in
        build-force)
                pkg__build
        ;;
        *)
                sinfo
                plimit
                case "$myPkgAction" in
                chop|init|purge|remove)
                        readonly DESTDIR="${STOW_DIR}/${PKG_NAME}"
                        msg "DESTDIR := ${DESTDIR}"
                        "pkg__${myPkgAction}"
                ;;
                build)
                        pkg__build
                        return 0
                ;;
                install)
                        pkg__install
                ;;
                test)
                        return 0
                ;;
                *)
                        die "unknown argument: '${myPkgAction}'"
                esac
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
