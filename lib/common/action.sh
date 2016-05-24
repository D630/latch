#!/usr/bin/env sh

action ()
{
        local _a

        for _a
        do
                . "${myRoot}/lib/action/${_a}.sh" && "${_a}_action";
        done
}

# vim: set ts=8 sw=8 tw=0 et :
