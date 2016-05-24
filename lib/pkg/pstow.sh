#!/usr/bin/env sh

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

# vim: set ts=8 sw=8 tw=0 et :
