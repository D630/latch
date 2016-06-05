#!/usr/bin/env sh

git_mirror ()
{
        if
                ! test -n "$2"
        then
                die "need two parameters"
        fi

        if
                [ "$(GIT_CONFIG="${MIRROR}/config" command git config --get core.bare)" = "true" ]
        then
                git_mirror_update
        else
                cd ..
                git_mirror_clone "$@"
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
