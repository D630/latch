#!/usr/bin/env sh

pinstall ()
{
        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/pinstall: Branching pkg version ..."
        gbranch "add" "$PKG_VERSION" "add pkg version ${PKG_VERSION}"

        unset -v \
                GIT_DIR \
                GIT_WORK_TREE;

        cd -- "$DISTDIR"

        msg "latch/pkg/pinstall: Invoking src_env() ..."
        src_env
        msg "latch/pkg/pinstall: Invoking src_prepare() ..."
        ( src_prepare )
        msg "latch/pkg/pinstall: Invoking src_build() ..."
        ( src_build )
        msg "latch/pkg/pinstall: Invoking src_check() ..."
        ( src_check )
        msg "latch/pkg/pinstall: Invoking src_install() ..."
        ( src_install )

        cd -- "$DESTDIR"

        export \
                GIT_DIR="${DESTDIR}/.git" \
                GIT_WORK_TREE="$DESTDIR";

        msg "latch/pkg/pinstall: Committing pkg version ..."
        gcommit "commit pkg version ${PKG_VERSION}"

        if
                ! [ "$stowedIs" = "<>" ]
        then
                msg "latch/pkg/pinstall: Checking out again ..."
                gcheckout "$stowedIs"
        fi

        msg "latch/pkg/pinstall: Registering pkg version ..."
        pregister "pkg"

        msg "latch/pkg/pinstall: DONE"

        # TODO
        chmod -R 755 "$DESTDIR"
}

# vim: set ts=8 sw=8 tw=0 et :
