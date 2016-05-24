#!/usr/bin/env sh

skel ()
{
        local _f

        for _f in "${myRoot}/share/skel/${1}/"?*
        do
                test -e "$_f" && command cp -- "$_f" "${2:-.}";
        done
}

# vim: set ts=8 sw=8 tw=0 et :
