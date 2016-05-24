#!/usr/bin/env sh

# When a branch is stowed, delete all other branches/installs.

chop_action ()
{
        local _b

        msg "src/chop: Checking out master ..."
        checkout master

        for _b in "${SRC_DIR}/"*.branch
        do
                if
                        [ -e "$_b" -a "$_b" != "${SRC_DIR}/${stowedIs}.branch" ]
                then
                        _b="${_b##*/}"
                        _b="${_b%.branch}"
                        msg "src/chop: Unregistering ${_b} ..."
                        unregister install "$_b"
                        msg "src/chop: Deleting ${_b} ..."
                        delete "$_b"
                else
                        msg "src/chop: Skipping ${_b}"
                fi
        done

        msg "src/chop: Checking out ${stowedIs} ..."
        checkout "$stowedIs"

        msg "src/chop: DONE"
}

# vim: set ts=8 sw=8 tw=0 et :
