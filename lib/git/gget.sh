#!/usr/bin/env sh

gget ()
case "$1" in
branchCnt)
        command git branch --list \
        | {
                i=0;
                while
                        IFS= read -r _ && : "$(( i+=1 ))";
                do
                        :
                done;
                printf '%d\n' "$((i - 1))"
        }
;;
currentBranch)
        command git rev-parse --abbrev-ref HEAD
;;
description)
        command git describe --always
;;
*)
        die "latch/gget/error: unknown argument -? ${1}"
esac

# vim: set ts=8 sw=8 tw=0 et :
