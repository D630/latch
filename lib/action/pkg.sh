#!/bin/sh

pkg__build ()
(
	DESTDIR=$myBuild/$KEY_NAME;
	DISTDIR=$myCheckout/$KEY_NAME;
	KEYDIR=$myKey/$KEY_NAME;

	readonly \
		DESTDIR \
		DISTDIR \
		KEYDIR;

	\msg "DISTDIR := $DISTDIR";
	\msg "DESTDIR := $DESTDIR";
	\msg "KEYDIR := $KEYDIR";

	command rm -fr "$DESTDIR" "$DISTDIR" "$KEYDIR";
	command mkdir -p "$DESTDIR";

	\gclone "$myMirror/$KEY_NAME.git" "$DISTDIR";
	\gclone "$myKeyRing" "$KEYDIR";

	cd -- "$KEYDIR";
	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$KEYDIR/.git;
	GIT_WORK_TREE=$KEYDIR;

	\gconfig --bool advice.detachedHead false;
	\gcheckout "$KEY_DESC";

	if
		test -e "$KEYDIR/LBUILD";
	then
		. "$KEYDIR/LBUILD";
	else
		\die "LBUILD file not found";
	fi;

	cd -- "$DISTDIR";
	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$DISTDIR/.git;
	GIT_WORK_TREE=$DISTDIR;

	\gconfig --bool advice.detachedHead false;
	\gcheckout "$DISTDIR_DESC";
	\gsubmodule update;

	(
		\msg "invoking src_env() ...";
		\src_env;
		\msg "invoking src_prepare() ...";
		(\src_prepare);
		\msg "invoking src_build() ...";
		(\src_build);
		\msg "invoking src_check() ...";
		(\src_check);
		\msg "invoking src_install() ...";
		(\src_install);
	);

	cd -- "$DESTDIR";

	command cp -fp -- "$KEYDIR/LBUILD" "$DESTDIR/.LBUILD";
	echo "$PKG_VERSION" > "$DESTDIR/.PKG_VERSION";
	command find -H "$DESTDIR/." \
		\( ! -name . -a ! -name .LFILES \) \
		-prune \
		> "$DESTDIR/.LFILES";
)

pkg__chop ()
(
	local _b;

	cd -- "$DESTDIR";

	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$DESTDIR/.git;
	GIT_WORK_TREE=$DESTDIR;

	command grep \
		-e "^$PKG_NAME|[0-9]*|[^|]*|[^|]*|$myContext|0$" "$myPkgList" | {
		while
			IFS='|' read -r _ _ p k _ _;
		do
			\msg "deleting '$p/$k' ...";
			\gbranch "delete" "$p/$k";
		done;
		\unregister chop-pkg;
	};

	\msg "cleaning ...";
	\gclean;

	\msg "setting rights ...";
	\rights "$STOW_DIR/$PKG_NAME";

	\msg "checking out '$stowedIs' ...";
	\gcheckout "$stowedIs";
)

pkg__init ()
(
	cd -- "$DESTDIR";

	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$DESTDIR/.git;
	GIT_WORK_TREE=$DESTDIR;

	\msg "initializing pkg repository ...";
	\ginit init;

	\msg "setting rights ...";
	\rights "$DESTDIR";
)

pkg__install ()
(
	__cd_gitdir ()
	{
		cd -- "$STOW_DIR/$PKG_NAME";

		export \
			GIT_DIR \
			GIT_WORK_TREE;

		GIT_DIR=$STOW_DIR/$PKG_NAME/.git;
		GIT_WORK_TREE=$STOW_DIR/$PKG_NAME;
	}

	__checkout_stowed ()
	{
		\msg "checkout master";
		\gcheckout "master";

		\msg "cleaning ...";
		\gclean;

		\msg "setting rights ...";
		\rights "$STOW_DIR/$PKG_NAME";

		\msg "checking out '$stowedIs' again ...";
		\gcheckout "$stowedIs";
	}

	__trap ()
	{
		\__cd_gitdir;
		\msg "Rolling back ...";
		\msg "deleting pkg version '$PKG_VERSION' ...";
		\gbranch "delete" "$PKG_VERSION";

		\msg "cleaning ...";
		\gclean;

		\msg "setting rights ...";
		\rights "$STOW_DIR/$PKG_NAME";

		if
			test "$stowedIs" = null;
		then
			:;
		else
			\msg "checking out '$stowedIs' again ...";
			\gcheckout "$stowedIs";
		fi;
	}

	DESTDIR=$myBuild/$KEY_NAME;
	readonly DESTDIR;
	\msg "DESTDIR := $DESTDIR";

	local f;
	for f in "$DESTDIR/.PKG_VERSION" "$DESTDIR/.LFILES" "$DESTDIR/.LBUILD";
	do
		test -e "$f" ||
			\die "a necessary build file does not exist: '$f'";
	done;

	\msg "comparing build pkg version with PKG_VERSION '$PKG_VERSION' ...";
	local p;
	IFS= read -r p < "$DESTDIR/.PKG_VERSION";
	test "$p" = "$PKG_VERSION" ||
		\die "build pkg version does not match PKG_VERSION: '$p <> $PKG_VERSION'";

	trap 'eval "\__trap ; exit $?"' 1 2 3 6 9 15 EXIT;

	\__cd_gitdir;

	\msg "branching pkg version '$PKG_VERSION'...";
	\gbranch "add" "$PKG_VERSION" "add pkg version $PKG_VERSION";

	\msg "moving pkg files to '$STOW_DIR/$PKG_NAME' ...";
	local f;
	while
		IFS= read -r f;
	do
		if
			test -d "$f";
		then
			command cp -fpR "$f/." "$STOW_DIR/$PKG_NAME/${f##*/}";
		elif
			test -f "$f";
		then
			command cp -fp "$f" "$STOW_DIR/$PKG_NAME/${f##*/}";
		else
			\die "cannot stat file: '$f'";
		fi;
	done < "$DESTDIR/.LFILES";

	\msg "committing pkg version '$PKG_VERSION' ...";
	\gcommit "commit pkg version $PKG_VERSION";

	trap - 1 2 3 6 9 15 EXIT;

	test "$stowedIs" = null ||
		\__checkout_stowed;

	\msg "registering pkg version '$PKG_VERSION' ...";
	\register pkg;
)

pkg__purge ()
{
	\msg "deinitializing pkg repo '$DESTDIR' ...";
	command rm -rf -- "$DESTDIR";

	\msg "unregistering all pkgs ...";
	\unregister any-pkg;
}

pkg__remove ()
(
	cd -- "$DESTDIR";

	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$DESTDIR/.git;
	GIT_WORK_TREE=$DESTDIR;

	\msg "deleting pkg version '$PKG_VERSION' ...";
	\gbranch "delete" "$PKG_VERSION";

	\msg "cleaning ...";
	\gclean;

	\msg "setting rights ...";
	\rights "$DESTDIR";

	test "$stowedIs" = null || {
		\msg "checking out '$stowedIs' again ...";
		\gcheckout "$stowedIs";
	};

	\msg "unregistering pkg version '$PKG_VERSION' ...";
	\unregister pkg;
)

pkg__main ()
{
	src_build		() { return 0 ; };
	src_check		() { return 0 ; };
	src_env			() { return 0 ; };
	src_install		() { return 0 ; };
	src_prepare		() { return 0 ; };

	DESTDIR=;
	DISTDIR=;
	DISTDIR_DESC=;
	KEYDIR=;
	KEY_DESC=;
	KEY_NAME=;
	PKG_NAME=;
	PKG_VERSION=;
	STOW_DIR=;
	STOW_TARGET=;
	arePacked=0;
	currentBranch=null;
	currentId=;
	isInitialized=false;
	isPacked=false;
	isStowed=false;
	myContext=;
	myHostname=;
	myIds=;
	myPkgAction=;
	myUser=;
	myXstowConfig=;
	stowedIs=null;
	useIds=;

	\import git pkg;

	eval set -- "$myArgs";

	myPkgAction=$1;
	readonly myPkgAction;
	shift 1;
	\msg "myPkgAction := $myPkgAction";

	\msg "myPkgList := $myPkgList";
	\env;
	\msg "KEY_NAME := ${KEY_NAME:=$1}";

	eval "$(
		\linfo "${3:-$KEY_NAME}" | {
			IFS='|' read -r _ _ myContext;
			IFS= read -r KEY_DESC;
			echo \
				"myContext=$myContext" \
				"KEY_DESC=$KEY_DESC";
		};
	)";
	\msg "KEY_DESC := ${KEY_DESC:?}";

	DISTDIR_DESC="$(minfo "${2:-HEAD}")";
	\msg "DISTDIR_DESC := ${DISTDIR_DESC:?}";

	readonly \
		DISTDIR_DESC \
		KEY_DESC \
		KEY_NAME \
		myContext \
		myPkgAction;

	if
		test -n "$myContext";
	then
		\msg "myContext := $myContext";
	else
		\die "myContext is null";
	fi;

	PKG_NAME=$(\pname "$KEY_NAME");
	PKG_VERSION=$DISTDIR_DESC/$KEY_DESC;

	\msg "PKG_NAME := $PKG_NAME";
	\msg "PKG_VERSION := $PKG_VERSION";

	readonly \
		PKG_NAME \
		PKG_VERSION;

	case $myPkgAction in
		(build)
			\pkg__build;;
		(*)
			\context "$myContext";
			\sinfo;
			\plimit;
			case $myPkgAction in
				(init|purge|chop|remove)
					DESTDIR=$STOW_DIR/$PKG_NAME;
					readonly DESTDIR;
					\msg "DESTDIR := $DESTDIR";
					"pkg__$myPkgAction";;
				(install)
					\pkg__install;;
				(*)
					\die "unknown argument: '$myPkgAction'";;
			esac;
	esac;
}

# vim: set ft=sh :
