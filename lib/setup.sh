#!/usr/bin/env sh

for _a in "${myRoot}/lib/common"/?*.sh
do
        . "$_a"
done

# vim: set ts=8 sw=8 tw=0 et :
