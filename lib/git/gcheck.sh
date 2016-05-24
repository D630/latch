#!/usr/bin/env sh

gcheck ()
case "$1" in
isBranch)
        command git show-ref \
                --verify \
                --quiet \
                "refs/heads/${2}" \
        2>/dev/null;
;;
isRemote)
        command git remote get-url "$2" 1>/dev/null 2>&1;
;;
isValidBranchFormat)
        command git check-ref-format --branch "$2" 1>/dev/null 2>&1;
;;
isGit)
        test -d ".git" &&
        command git rev-parse --git-dir 1>/dev/null 2>&1;
;;
isValidUri)
        GIT_TERMINAL_PROMPT=0 \
        command git ls-remote -hq --exit-code "$2" 1>/dev/null 2>&1;
;;
*)
        die "latch/gcheck/error: unknown argument -? ${1}"
esac

# vim: set ts=8 sw=8 tw=0 et :
