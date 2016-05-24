#!/usr/bin/env sh

mr_action ()
(
        bin=
        myMrAction=
        ytt=

        eval set -- "$myArgs"

        if
                [ "$#" -ne 1 -o "$1" = "{}" ]
        then
                die "latch/mr/error: unknown arguments -? ${@}"
        else
                readonly myMrAction="$1"
        fi

        msg "latch/mr: myMrAction -> ${myMrAction}"

        cd -- "${myMirror%/*}"

        if
                ! test -r "$mySrcList"
        then
                skel "src" .
        fi
        command cp -f -- "$mySrcList" "${mySrcList}~"
        msg "latch/mr: mySrcList -> ${mySrcList}"

        if
                command -v "mawk" 1>/dev/null 2>&1;
        then
                bin="mawk"
        else
                bin="awk"
        fi

        ytt="$(command tty)"
        readonly ytt
        export ytt

        command rm -f -- "${myLog}"/?*.log

        command "$bin" \
                -f "${mySrcList}" \
                -f "${myRoot}/lib/awk/common.awk" \
                -f "${myRoot}/lib/awk/mr.awk" -- -a "$myMrAction" \
        | command xargs -E "" -L 1 -P 6 -x -r sh -c '
                set -e;
                exec >> "${myLog}/${$}.log";
                exec 2>&1;
                echo "latch/mr: Processing ${1} ...";
                . "${myRoot}/lib/setup.sh";
                import mr;
                WORKTREE="${myCheckout}/${1%.git}";
                MIRROR="${myMirror}/${1}";
                command mkdir -p "$MIRROR" "$WORKTREE";
                cd -- "$MIRROR";
                export MIRROR WORKTREE;
                eval "$2";
                command cat "${myLog}/${$}.log" > "$ytt";
        ' sh;

        msg "latch/mr: DONE"
)

# vim: set ts=8 sw=8 tw=0 et :
