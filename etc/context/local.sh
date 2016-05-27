#!/usr/bin/env sh

local_context ()
{
        useId="1000"
        STOW_DIR="/home/stow"
        STOW_TARGET="/home/${myUser}"
        myXstowConfig="${myRoot}/etc/xstow/local.ini"
}

# vim: set ts=8 sw=8 tw=0 et :
