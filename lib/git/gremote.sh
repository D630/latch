#!/usr/bin/env sh

gremote ()
case "$1" in
add)
        command git remote add "$2" "$3"
;;
remove)
        command git remote remove "$2"
;;
*)
        die "latch/gremote/error: unknown argument -? ${1}"
esac

# vim: set ts=8 sw=8 tw=0 et :
