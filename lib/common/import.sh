#!/usr/bin/env sh

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

# vim: set ts=8 sw=8 tw=0 et :
