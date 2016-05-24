#!/usr/bin/env sh

ginit ()
{
        command git init
        command git config --local user.name "d630"
        command git config --local user.email "d630@posteo.net"
        command git commit --allow-empty -m "${1:-init}"
}

# vim: set ts=8 sw=8 tw=0 et :
