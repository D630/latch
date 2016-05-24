#!/usr/bin/env sh

context ()
{
        . "${myRoot}/etc/context/${1}.sh" && "${1}_context";
}

# vim: set ts=8 sw=8 tw=0 et :
