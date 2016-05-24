#!/usr/bin/env sh

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

# vim: set ts=8 sw=8 tw=0 et :
