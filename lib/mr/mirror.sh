#!/bin/sh

git_mirror ()
{
	test -n "$2" ||
		die "need two parameters";

	if
		test \
			"$(
				GIT_CONFIG=$MIRROR/config \
					command git config --get core.bare;
			)" \
			= \
			true;
	then
			\git_mirror_update;
	else
			cd ..
			\git_mirror_clone "$@";
	fi;
}

git_mirror_clone ()
{
	command git clone --mirror -- "$@";
}

git_mirror_update ()
{
	command git remote update --prune;
	# command git fetch --all --prune;
}

# vim: set ft=sh :
