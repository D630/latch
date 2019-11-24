#!/bin/sh

for _a in "$myRoot/lib/common/"?*.sh;
do
	. "$_a";
done;

# vim: set ft=sh :
