#!/usr/bin/env sh

punstow ()
{
        import stow

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/punstow: Checking out '${PKG_VERSION}' ..."
        gcheckout "$PKG_VERSION"

        unset -v \
                GIT_DIR \
                GIT_WORK_TREE;

        msg "latch/pkg/punstow: Invoking unstow_prae() ..."
        (
                unstow_prae
        )

        msg "latch/pkg/punstow: Unstowing ${PKG_VERSION} ..."
        (
                cd ..
                sunstow "${PKG_NAME##*/}"
        )

        msg "latch/pkg/punstow: Invoking unstow_post() ..."
        (
                unstow_post
        )

        msg "latch/pkg/punstow: Unregistering stowed version ..."
        punregister "stow"

        msg "latch/pkg/punstow: DONE"
}

# vim: set ts=8 sw=8 tw=0 et :
