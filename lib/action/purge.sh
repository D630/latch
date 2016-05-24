#!/usr/bin/env sh

purge_action ()
{
        case "$stowedIs" in
        "$STOW_BRANCH")
                action unstow
        ;;
        "<>")
                :
        ;;
        *)
                msg "src/purge: Executing '${myRoot}/src unstow ${SRC_DIR#${myRoot}/mr/}/${stowedIs}.branch' ..."
                "${myRoot}/src" unstow "${SRC_DIR#${myRoot}/mr/}/${stowedIs}.branch"
        esac

        msg "src/purge: Deinitializing ..."
        deinit
        msg "src/purge: Unregistering all installs ..."
        unregister all-installs

        msg "src/purge: DONE"
}

# vim: set ts=8 sw=8 tw=0 et :
