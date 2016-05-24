#!/usr/bin/env sh

fring ()
if
        gcheck "isGit"
then
        die "latch/forge/fring/error: latchkey ring already hammered"
else
        msg "latch/forge/fring: Hammering latchkey ring ..."
        ginit "hammer latchkey ring"
        msg "latch/forge/fring: Forging latchkey ring ..."
        printf '%s' "" > LREMOTE;
        gcommit "forge latchkey ring"
fi

# vim: set ts=8 sw=8 tw=0 et :
