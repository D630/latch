#!/usr/bin/env sh

pkg_action ()
(
        src_build       () { return 0 ; }
        src_check       () { return 0 ; }
        src_env         () { return 0 ; }
        src_install     () { return 0 ; }
        src_prepare     () { return 0 ; }
        stow_post       () { return 0 ; }
        stow_prae       () { return 0 ; }
        unstow_post     () { return 0 ; }
        unstow_prae     () { return 0 ; }

        DESTDIR= \
        DISTDIR= \
        DISTDIR_DESC= \
        KEY_DESC= \
        KEY_NAME= \
        PKG_NAME= \
        PKG_VERSION= \
        STOW_DIR= \
        STOW_TARGET= \
        _g= \
        _i= \
        arePacked=0 \
        currentBranch="<>" \
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
        stowedIs="<>" \
        useId=;

        import git pkg

        eval set -- "$myArgs"

        # TODO
        if
                [ "$1" = "unstow-curr" ]
        then
                shift 1
                local _p
                _p="$(
                        __p="$(
                                command sed -e 's|/|::|g' <<S
${1}
S
                        )";
                        command grep -e "^${__p}|[^|]*|[^|]*|[^|]*|1\$" "$myPkgList" \
                        | {
                                IFS='|' read -r _ d k _ _ || :;
                                echo "${d:-_}" "${k:-_}"
                        };
                )"
                eval set -- "unstow" "$1" "$_p"
        fi

        readonly myPkgAction="$1"
        shift 1
        msg "latch/pkg: myPkgAction -> ${myPkgAction}"

        msg "latch/pkg: myPkgList -> ${myPkgList}"

        currentId="$(command id -u)"
        msg "latch/pkg: currentId -> ${currentId}"
        myHostname="$(command hostname -s)"
        msg "latch/pkg: myHostname -> ${myHostname}"
        readonly \
                currentId \
                myHostname;

        . "${myRoot}/etc/env/${myHostname}.sh"
        msg "latch/pkg: myUser -> ${myUser}"
        msg "latch/pkg: myIds -> ${myIds}"
        IFS=':' read -r _i _g <<IN
${myIds}
IN
        [ -n "$_i" -a -n "$_g" ] || die "latch/pkg/error: myIds -? '${myIds}'";

        msg "latch/pkg: KEY_NAME -> ${KEY_NAME:=$1}"

        KEY_DESC="$(
                cd -- "$myKeyRing"

                export \
                        GIT_DIR="${myKeyRing}/.git" \
                        GIT_WORK_TREE="$myKeyRing";

                if
                        gcheckout "${3:-$KEY_NAME}" 1>/dev/null 2>&1;
                then
                        command chown "$myIds" "./.git/HEAD" "./.git/index" "./"?*
                        gget "description" 2>/dev/null;
                else
                        msg "latch/pkg/error: could not check out: '${3:-$KEY_NAME}'"
                        die "latch/pkg/error: latchkey not hammered? '${KEY_NAME}'"
                fi
        )"
        msg "latch/pkg: KEY_DESC -> ${KEY_DESC}"

        msg "latch/pkg: DISTDIR -> ${DISTDIR:="${myCheckout}/${KEY_NAME}"}"
        command mkdir -p "$DISTDIR"

        DISTDIR_DESC="$(
                cd -- "$DISTDIR"

                export \
                        GIT_DIR="${DISTDIR}/.git" \
                        GIT_WORK_TREE="$DISTDIR";

                if
                        gcheckout "${2:-master}" 1>/dev/null 2>&1;
                then
                        command chown -R "$myIds" "./.git/HEAD" "./.git/index"
                        gget "description" 2>/dev/null;
                else
                        msg "latch/pkg/error: could not check out: '${2:-master}'"
                        die "latch/pkg/error: DISTDIR not checked out by 'mr wupdate'? '${DISTDIR}'"
                fi
        )"
        msg "latch/pkg: DISTDIR_DESC -> ${DISTDIR_DESC}"

        readonly \
                DISTDIR \
                DISTDIR_DESC \
                KEY_DESC \
                KEY_NAME \
                myPkgAction \
                myIds \
                myUser;

        pconfigure
        . "${myKeyRing}/LBUILD"
        plimit

        case "$myPkgAction" in
        info)
                :
        ;;
        chop|init|purge|remove)
                p${myPkgAction}
        ;;
        install|stow|unstow)
                p${myPkgAction}
        ;;
        *)
                die "latch/pkg/error: unknown argument -? '${myPkgAction}'"
        esac

        msg "latch/pkg: DONE"
)

# vim: set ts=8 sw=8 tw=0 et :
