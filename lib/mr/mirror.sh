#!/usr/bin/env sh

git_mirror_mirror ()
{
        if
                ! test -n "$2"
        then
                die "latch/mr/mirror/error: need two parameters"
        fi
        if
                [ "$(GIT_CONFIG="${MIRROR}/config" command git config --get core.bare)" = "true" ]
        then
                if
                        git_mirror_update
                then
                        msg "latch/mr/mirror: DONE"
                fi
        else
                cd ..
                if
                        git_mirror_clone "$@"
                then
                        msg "latch/mr/mirror: DONE"
                fi
        fi
}

git_mirror_clone ()
{
        command git clone -v --mirror --recursive --progress -- "$@"
}

git_mirror_update ()
{
        command git remote update --prune
}

# vim: set ts=8 sw=8 tw=0 et :
