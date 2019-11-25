#!/bin/sh

# shellcheck disable=SC2154

__plimit ()
{
	# shellcheck disable=SC2015
	test "$arePacked" -gt 1 &&
		_l="$_l chop" ||
		:;
}

_plimit () {
	if
		test "$stowedIs" != null;
	then
		case $myPkgAction in
			(purge)
				\die "current stowed version must be unstowed: '$stowedIs'";;
		esac;
		\__plimit;
	else
		:;
	fi;
}

plimit ()
{
	local _l

	case $isInitialized::$isPacked::$isStowed in
		(false::*)
			_l="init build";;
		(true::false::*)
			_l="purge build install";
			\_plimit;;
		(true::true::false)
			_l="purge build remove";
			\_plimit;;
		(true::true::true)
			_l=build;
			\__plimit;;
	esac;

	if
		test "${_l:-_}" = _;
	then
		\die "alarm. something went wrong, really";
	else
		_l=" $_l ";
	fi;

	\msg "{${_l}}";

	case $_l in
		(*" $myPkgAction "*)
			:;;
		(*)
			\die "myPkgAction cannot be executed: '$myPkgAction'";
	esac;
}

# vim: set ft=sh :
