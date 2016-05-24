#!/usr/bin/env sh

action ()
{
        . "${myRoot}/lib/action/${1}.sh" && "${1}_action";
}

context ()
{
        . "${myRoot}/etc/context/${1}.sh" && "${1}_context";
}

die ()
{
        msg "$@"
        exit 1
}

import ()
{
        local \
                __i \
                _i;

        for _i
        do
                if
                        test -d "${myRoot}/lib/${_i}/"
                then
                        for __i in "${myRoot}/lib/${_i}/"?*.sh
                        do
                                . "$__i"
                        done
                else
                        . "${myRoot}/lib/${_i}.sh"
                fi
        done
}

let ()
{
        IFS=, command eval test '$(( ${*} ))' -ne '0'
}

msg ()
{
        printf '%s\n' "$@" 1>&2;
}

skel ()
{
        local _f

        for _f in "${myRoot}/share/skel/${1}/"?*
        do
                test -e "$_f" && command cp -- "$_f" "${2:-.}";
        done
}

# vim: set ts=8 sw=8 tw=0 et :
