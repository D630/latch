#!/bin/sh

mr__main ()
(
	test "$(idu)" -eq 0 &&
		\die "may not run as superuser";

	bin=;
	myMrAction=;
	ytt=;

	eval set -- "$myArgs";

	if
		test "$#" -ne 1 -o "$1" = "{}";
	then
		\die "unknown arguments: '$*'";
	else
		myMrAction=$1;
		readonly myMrAction;
	fi

	\msg "myMrAction := $myMrAction";

	cd -- "${myMirror%/*}";

	test -e "$myMirrorList" ||
		\skel "mirror" .
	command cp -f -- "$myMirrorList" "$myMirrorList~";
	\msg "myMirrorList := $myMirrorList";

	if
		command -v mawk 1>/dev/null 2>&1;
	then
		bin=mawk;
	else
		bin=awk;
	fi;

	ytt=$(command tty);
	readonly ytt;
	export ytt;

	command mkdir -p "$myLog/mr";
	command rm -f -- "$myLog/mr/"?*.log;

	command "$bin" \
		-f "$myMirrorList" \
		-f "$myRoot/lib/awk/common.awk" \
		-f "$myRoot/lib/awk/mr.awk" \
		-- -a "$myMrAction" |
	command xargs -E '' -L 1 -P 4 -x -r sh -c '
		set -e;
		exec >> "${myLog}/mr/${$}.log";
		exec 2>&1;
		echo "latch/mr: processing $1 ...";
		. "$myRoot/lib/setup.sh";
		\import mr;
		# WORKTREE=$myCheckout/${1%.git};
		MIRROR=$myMirror/$1;
		command mkdir -p "$MIRROR" # "$WORKTREE";
		cd -- "$MIRROR";
		export MIRROR # WORKTREE;
		eval "$2";
		# TODO
		command cat "$myLog/mr/$$.log" > "$ytt";
	' sh;
)

# vim: set ft=sh :
