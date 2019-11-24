#!/usr/bin/env sh

gbranch ()
case "$1" in
add)
        gcheckout "master"
        command git checkout --orphan "$2"
        command rm -rfv -- \
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
        die "unknown argument: '${1}'"
esac

gcheck ()
case "$1" in
isBranch)
        command git show-ref \
                --verify \
                --quiet \
                "refs/heads/${2}" \
        2>/dev/null;
;;
isChanged)
        command git diff \
                --exit-code \
                --name-only \
                --quiet \
                -- "$2";
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
        die "unknown argument: '${1}'"
esac

gcheckout ()
{
        command git checkout -f "${1:-master}"
}

gclean ()
{
        command git clean -dfx
}

gclone ()
{
        command git clone --no-checkout --local "$1" "$2";
}

gcommit ()
{
        command git add -f -A
        command git commit -m "$1"
        command git repack -a -d && command git gc --prune;
}

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
        command git describe --always "${2:+$2}"
;;
stowedBranch)
        local b
        b="$(command git rev-parse -q --verify stowed~0 || :;)"
        if
                test -n "$b"
        then
                command git branch --contains "$b" \
                | {
                        IFS=' ' read -r _ b;
                        echo "$b"
                }
        else
                echo "null"
        fi
;;
*)
        die "unknown argument: '${1}'"
esac

ginit ()
{
        command git init
        command git config --local user.name "latch"
        command git config --local user.email "latch@example.org"
        command git commit --allow-empty -m "${1:-init}"
}

gremote ()
case "$1" in
add)
        command git remote add "$2" "$3"
;;
remove)
        command git remote remove "$2"
;;
*)
        die "unknown argument: '${1}'"
esac

greset ()
case "$1" in
hard)
        command git reset --hard
;;
*)
        die "unknown argument: '${1}'"
esac

gsubmodule ()
case "$1" in
update)
        command git submodule sync --recursive
        command git submodule update --init --recursive --jobs 4
;;
*)
        die "unknown argument: '${1}'"
esac

gtag ()
case "$1" in
add)
        command git tag -f -m "stowed" stowed "$PKG_VERSION"
;;
delete)
        command git tag -d stowed
;;
*)
        die "unknown argument: '${1}'"
esac

gconfig ()
{
    command git config --local "$@"
}

# vim: set ts=8 sw=8 tw=0 et :
