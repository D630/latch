#!/bin/sh

rehash__main ()
(
	test "$(idu)" -eq 0 &&
		\die "may not run as superuser";

	bin=;
	myLInfo=$myKeyRing/LINFO;

	\import git;

	cd -- "$myKeyRing";
	(
		cd ..;

		test -e "$myMirrorList" ||
			\skel "mirror" .;

		command cp -f -- "$myMirrorList" "$myMirrorList~";
		\msg "myMirrorList := $myMirrorList";
	)

	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$myKeyRing/.git;
	GIT_WORK_TREE=$myKeyRing;

	\gcheckout master 1>/dev/null 2>&1;

	export myLInfo
	test -e "$myLInfo" ||
		printf '%s' "" > "$myLInfo";

	if
		command -v mawk 1>/dev/null 2>&1;
	then
		bin=mawk;
	else
		bin=awk;
	fi;

	exec "$bin" \
		-f "$myMirrorList" \
		-f "$myRoot/lib/awk/common.awk" \
		-f "$myRoot/lib/awk/rehash.awk";
)

# vim: set ft=sh :
