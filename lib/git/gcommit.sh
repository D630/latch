#!/usr/bin/env sh

gcommit ()
{
        command git add -A ./*
        command git commit -m "$1"
        command git repack -a -d && command git gc --prune;
}

# vim: set ts=8 sw=8 tw=0 et :
