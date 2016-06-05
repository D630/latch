#!/usr/bin/env sh

rehash__main ()
(
        if
                [ "$(idu)" -eq 0 ]
        then
                die "may not run as superuser"
        fi

        bin= \
        myLInfo="${myKeyRing}/LINFO";

        import git

        cd -- "$myKeyRing"
        (
                cd ..

                if
                        ! test -e "$myMirrorList"
                then
                        skel "mirror" .
                fi

                command cp -f -- "$myMirrorList" "${myMirrorList}~"
                msg "myMirrorList := ${myMirrorList}"
        )

        export \
                GIT_DIR="${myKeyRing}/.git" \
                GIT_WORK_TREE="$myKeyRing";

        gcheckout "master" 1>/dev/null 2>&1

        if
                ! test -e "$myLInfo"
        then
                printf '%s' "" > "$myLInfo";
        fi
        export myLInfo

        if
                command -v "mawk" 1>/dev/null 2>&1;
        then
                bin="mawk"
        else
                bin="awk"
        fi

        command "$bin" \
                -f "${myMirrorList}" \
                -f "${myRoot}/lib/awk/common.awk" \
                -f "${myRoot}/lib/awk/rehash.awk";
)

# vim: set ts=8 sw=8 tw=0 et :
