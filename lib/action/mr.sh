#!/usr/bin/env sh

mr__main ()
(
        bin=
        myMrAction=
        ytt=

        eval set -- "$myArgs"

        if
                [ "$#" -ne 1 -o "$1" = "{}" ]
        then
                die "unknown arguments: '${@}'"
        else
                readonly myMrAction="$1"
        fi

        msg "myMrAction := ${myMrAction}"

        cd -- "${myMirror%/*}"

        if
                ! test -e "$myMirrorList"
        then
                skel "mirror" .
        fi
        command cp -f -- "$myMirrorList" "${myMirrorList}~"
        msg "myMirrorList := ${myMirrorList}"

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
                -f "${myMirrorList}" \
                -f "${myRoot}/lib/awk/common.awk" \
                -f "${myRoot}/lib/awk/mr.awk" \
                -- -a "$myMrAction" \
        | command xargs -E "" -L 1 -P 6 -x -r sh -c '
                set -e;
                exec >> "${myLog}/${$}.log";
                exec 2>&1;
                echo "latch/mr: processing ${1} ...";
                . "${myRoot}/lib/setup.sh";
                import mr;
                #WORKTREE="${myCheckout}/${1%.git}";
                MIRROR="${myMirror}/${1}";
                command mkdir -p "$MIRROR" #"$WORKTREE";
                cd -- "$MIRROR";
                export MIRROR #WORKTREE;
                eval "$2";
                # TODO
                command cat "${myLog}/${$}.log" > "$ytt";
        ' sh;
)

# vim: set ts=8 sw=8 tw=0 et :
