#!/usr/bin/env sh

fcommit ()
{
        if
                ! gcheck "isGit"
        then
                die "latch/forge/fcommit/error: latchkey ring not forged"
        fi

        local b
        b="$(gget "currentBranch")"

        [ "$b" = "master" ] && b="latchkey ring";

        msg "latch/forge/fcommit: Forging latchkey '${b}' ..."
        gcommit "forge latchkey ${b}" || :;
}

# vim: set ts=8 sw=8 tw=0 et :
