#!/usr/bin/env sh

gcheckout ()
{
        command git checkout -f "${1:-master}"
}

# vim: set ts=8 sw=8 tw=0 et :
