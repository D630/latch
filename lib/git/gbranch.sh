#!/usr/bin/env sh

gbranch ()
case "$1" in
add)
        gcheckout "master"
        command git checkout --orphan "$2"
        command rm -rf -- \
                ./.git/index \
                ./.git/COMMIT_EDITMSG \
                ./.git/description \
                ./.git/hooks \
                ./.git/logs;
        gclean
        command git commit --allow-empty -m "${3:-init}"
;;
delete)
        gcheckout "master"
        command git branch -df "$2"
;;
*)
        die "latch/gbranch/error: unknown argument -? ${1}"
esac

# vim: set ts=8 sw=8 tw=0 et :
