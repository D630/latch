#!/usr/bin/env sh

git_worktree_clone ()
{
        if
                cd -- "${WORKTREE}/.git" 1>/dev/null 2>&1;
        then
                msg "latch/mr/clone: Already cloned: '${WORKTREE}'"
                msg "latch/mr/clone: Skipping ${WORKTREE} ..."
        else
                cd -- "${WORKTREE%/*}"
                worktree_clone "$MIRROR"
        fi

        msg "latch/mr/clone: DONE"
}

git_worktree_purge ()
{
        worktree_purge "$WORKTREE"
        msg "latch/mr/purge: DONE"
}

git_worktree_rebase ()
{
        command git rebase -v \
                --stat --autostash \
                --preserve-merges -- origin/HEAD;
}

git_worktree_reset ()
{
        command git clean -dfx
        command git reset --hard origin/HEAD
}

git_worktree_update ()
{
        if
                cd -- "${WORKTREE}/.git" 1>/dev/null 2>&1;
        then
                cd ..
                if
                        command git checkout -f master
                        worktree_fetch
                        worktree_check
                then
                        "git_worktree_${1:-reset}"
                        worktree_update
                else
                        msg "latch/mr/update: No work tree update needed"
                fi
        else
                msg "latch/mr/update: No git work tree available"
                cd -- "${WORKTREE%/*}"
                worktree_clone "$MIRROR"
                worktree_update
        fi

        msg "latch/mr/update: DONE"
}

worktree_check ()
{
        ! [ "$(command git rev-parse HEAD)" = "$(command git rev-parse @{u})" ]
}

worktree_clone ()
{
        command git clone -v --local --progress --recursive -- "$1"
}

worktree_fetch ()
{
        command git fetch -fpt -j 5 --all --recurse-submodules=on-demand \
                --progress;
}

worktree_purge ()
if
        test -d "${1}/.git"
then
        msg "latch/mr/purge: Purging ${1} ..."
        command rm -fr -- "$1"
else
        msg "latch/mr/purge: Not a repo: '${1}'"
        msg "latch/mr/purge: Skipping ${1} ..."
fi

worktree_update ()
{
        # TODO
        echo "${WORKTREE#${myCheckout}/}" >> "${myRoot}/var/UPDATES";
        command sort -u -o "${myRoot}/var/UPDATES" "${myRoot}/var/UPDATES"
}

# vim: set ts=8 sw=8 tw=0 et :
