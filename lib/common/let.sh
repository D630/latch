#!/usr/bin/env sh

let ()
{
        IFS=, command eval test '$(( ${*} ))' -ne '0'
}

# vim: set ts=8 sw=8 tw=0 et :
