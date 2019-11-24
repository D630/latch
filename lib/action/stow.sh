#!/usr/bin/env sh

stow__add ()
(
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "checking out '${PKG_VERSION}' ..."
        gcheckout "$PKG_VERSION"

        msg "cleaning ..."
        gclean

        msg "setting rights ..."
        rights "$DESTDIR"

        . "./.LBUILD"

        msg "invoking stow_prae() ..."
        (
                unset -v \
                        GIT_DIR \
                        GIT_WORK_TREE;
                stow_prae
        )

        msg "stowing '${PKG_VERSION}' ..."
        (
                unset -v \
                        GIT_DIR \
                        GIT_WORK_TREE;
                cd ..
                sstow "$PKG_NAME"
        )

        msg "invoking stow_post() ..."
        (
                unset -v \
                        GIT_DIR \
                        GIT_WORK_TREE;
                stow_post
        )

        msg "tagging '${PKG_VERSION}' ..."
        gtag "add"

        msg "registering '${PKG_VERSION}' ..."
        register "stow"
)

stow__delete ()
(
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "checking out '${PKG_VERSION}' ..."
        gcheckout "$PKG_VERSION"

        msg "setting rights ..."
        rights "$DESTDIR"

        . "./.LBUILD"

        msg "invoking unstow_prae() ..."
        (
                unset -v \
                        GIT_DIR \
                        GIT_WORK_TREE;
                unstow_prae
        )

        msg "unstowing '${PKG_VERSION}' ..."
        (
                unset -v \
                        GIT_DIR \
                        GIT_WORK_TREE;
                cd ..
                sunstow "$PKG_NAME"
        )

        msg "invoking unstow_post() ..."
        (
                unset -v \
                        GIT_DIR \
                        GIT_WORK_TREE;
                unstow_post
        )

        msg "untagging '${PKG_VERSION}' ..."
        gtag "delete"

        msg "unregistering stowed version '${PKG_VERSION}' ..."
        unregister "stow"
)

stow__main ()
{
        stow_post       () { return 0 ; }
        stow_prae       () { return 0 ; }
        unstow_post     () { return 0 ; }
        unstow_prae     () { return 0 ; }

        DISTDIR_DESC= \
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
        isStowed="false"
        myContext= \
        myHostname= \
        myIds= \
        myStowAction= \
        myUser= \
        myXstowConfig= \
        stowedIs="null" \
        useIds=;

        import git stow

        eval set -- "$myArgs"

        readonly myStowAction="$1"
        shift 1
        msg "myStowAction := ${myStowAction}"

        msg "myPkgList := ${myPkgList}"
        env
        msg "KEY_NAME := ${KEY_NAME:=$1}"

        PKG_NAME="$(pname "$KEY_NAME")"

        msg "PKG_NAME := ${PKG_NAME}"
        : "${PKG_VERSION:=${2:-master}}"

        local _p
        if
                [ "$PKG_VERSION" = "master" ]
        then
                _p="$(
                        # TODO
                        if
                                [ "$myStowAction" = "delete" ]
                        then
                                _s=1
                        else
                                _s=0
                        fi
                        command grep \
                                -e "^${PKG_NAME}|[0-9]*|[^|]*|[^|]*|[^|]*|${_s}\$" \
                                "$myPkgList" \
                        | command sort -t '|' -k 2nr;
                )"
                if
                        test -n "$_p"
                then
                        IFS='|' read -r _ _ DISTDIR_DESC KEY_DESC myContext _ <<S
${_p}
S
                else
                        die "there is no pkg version of '${KEY_NAME}', that can be used with '${myStowAction}'"
                fi
                PKG_VERSION="${DISTDIR_DESC:?}/${KEY_DESC:?}"
        else
                IFS='/' read -r DISTDIR_DESC KEY_DESC <<IN
${PKG_VERSION}
IN
                _p="$(
                        command grep \
                                -e "^${PKG_NAME}|[0-9]*|${DISTDIR_DESC:?}|${KEY_DESC:?}|[^|]*|[01]\$" \
                                "$myPkgList";
                )"
                IFS='|' read -r _ _ _ _ myContext _ <<S
${_p}
S
        fi

        msg "PKG_VERSION := ${PKG_VERSION}"
        msg "DISTDIR_DESC := ${DISTDIR_DESC}"
        msg "KEY_DESC := ${KEY_DESC}"

        readonly \
                DISTDIR_DESC \
                KEY_DESC \
                KEY_NAME \
                PKG_NAME \
                PKG_VERSION \
                myContext \
                myStowAction;

        if
                test -n "$myContext"
        then
                msg "myContext := ${myContext}"
                context "$myContext"
        else
                die "myContext is null"
        fi

        sinfo
        slimit

        readonly DESTDIR="${STOW_DIR}/${PKG_NAME}"
        msg "DESTDIR := ${DESTDIR}"
        exit

        case "$myStowAction" in
        add|delete)
                "stow__${myStowAction}"
        ;;
        *)
                die "unknown argument: '${myStowAction}'"
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
