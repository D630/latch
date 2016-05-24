#!/usr/bin/env sh

premove ()
{
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/premove: Deleting pkg version ${PKG_VERSION} ..."
        gbranch "delete" "$PKG_VERSION"

        msg "latch/pkg/premove: Cleaning ..."
        gclean

        if
                ! let "$arePacked - 1 > 0"
        then
                msg "latch/pkg/premove: Deinitializing pkg repository ..."
                pdeinit
        fi

        msg "latch/pkg/premove: Unregistering pkg version ..."
        punregister "pkg"

        msg "latch/pkg/premove: DONE"
}

# vim: set ts=8 sw=8 tw=0 et :
