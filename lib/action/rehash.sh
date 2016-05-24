#!/usr/bin/env sh

rehash_action ()
(
        bin= \
        myLRemote="${myKeyRing}/LREMOTE";

        import git

        cd -- "$myKeyRing"
        (
                cd ..

                if
                        ! test -r "$mySrcList"
                then
                        skel "src" .
                fi

                command cp -f -- "$mySrcList" "${mySrcList}~"
                msg "latch/rehash: mySrcList -> ${mySrcList}"
        )

        export \
                GIT_DIR="${myKeyRing}/.git" \
                GIT_WORK_TREE="$myKeyRing";

        gcheckout "master"

        if
                ! test -e "$myLRemote"
        then
                printf '%s' "" > "$myLRemote";
        fi
        export myLRemote

        if
                command -v "mawk" 1>/dev/null 2>&1;
        then
                bin="mawk"
        else
                bin="awk"
        fi

        command "$bin" \
                -f "${mySrcList}" \
                -f "${myRoot}/lib/awk/common.awk" \
                -f "${myRoot}/lib/awk/rehash.awk";

        msg "latch/rehash: DONE"
)

# vim: set ts=8 sw=8 tw=0 et :
