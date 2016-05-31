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
        myKey= \
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
                local _p __p stowed is
                __p="$(
                        command sed -e 's|/|::|g' <<S
${1}
S
                )";
                _p="$(
                        command grep -e "^${__p}|[^|]*|[^|]*|[^|]*|1\$" \
                                "$myPkgList";
                )"
                IFS='|' read -r _ stowed is _ _ <<S
${_p}
S
                eval set -- "unstow" "$1" "${stowed:?}" "${is:?}"
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

        eval "$(
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
                                "${KEY_NAME}" \
                                -- ./LINFO 2>/dev/null;
                then
                        gget "description" "${3:-$KEY_NAME}" 2>/dev/null;
                else
                        die "latch/pkg/error: Could not describe '${3:-$KEY_NAME}' in '${myKeyRing}'"
                fi \
                | {
                        IFS='|' read -r _ _ myContext;
                        IFS= read -r KEY_DESC;
                        echo myContext="$myContext" KEY_DESC="$KEY_DESC"
                }
        )"
        msg "latch/pkg: KEY_DESC -> ${KEY_DESC:?}"

        DISTDIR_DESC="$(
                cd -- "${myMirror}/${KEY_NAME}.git"

                export GIT_DIR="${myMirror}/${KEY_NAME}.git"

                if
                        ! gget "description" "${2:-HEAD}" 2>/dev/null;
                then
                        die "latch/pkg/error: Could not describe '${2:-HEAD}' in '${myMirror}/${KEY_NAME}.git'"
                fi
        )"
        msg "latch/pkg: DISTDIR_DESC -> ${DISTDIR_DESC}"

        if
                test -n "$myContext"
        then
                msg "latch/pkg: myContext -> ${myContext}"
        else
                die "latch/pkg/error: myContext -?"
        fi

        readonly \
                DISTDIR_DESC \
                KEY_DESC \
                KEY_NAME \
                myContext \
                myIds \
                myPkgAction \
                myUser;

        pconfigure
        plimit

        case "$myPkgAction" in
        test)
                :
        ;;
        chop|init|purge|remove)
                readonly DESTDIR="${STOW_DIR}/${PKG_NAME}"
                msg "latch/pkg/p${myPkgAction}: DESTDIR -> ${DESTDIR}"
                p${myPkgAction}
        ;;
        stow|unstow)
                readonly \
                        DESTDIR="${STOW_DIR}/${PKG_NAME}" \
                        myKey="${myRoot}/tmp/key/${PKG_NAME}";
                msg "latch/pkg/p${myPkgAction}: DESTDIR -> ${DESTDIR}"
                msg "latch/pkg/p${myPkgAction}: myKey -> ${myKey}"
                command rm -fr "$myKey"
                gclone "$myKeyRing" "$myKey"
                cd -- "$myKey"
                export \
                        GIT_DIR="${myKey}/.git" \
                        GIT_WORK_TREE="$myKey";
                gcheckout "$KEY_DESC"
                . "${myKey}/LBUILD"
                p${myPkgAction}
        ;;
        install)
                pinstall
        ;;
        *)
                die "latch/pkg/error: unknown argument -? '${myPkgAction}'"
        esac

        msg "latch/pkg: DONE"
)

# vim: set ts=8 sw=8 tw=0 et :
