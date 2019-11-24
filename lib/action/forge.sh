#!/bin/sh

forge__add ()
{
	_fadd ()
	{
		printf '%s|%s|%s\n' "$b" "$u" "$c";
	}

	local \
		_r \
		u \
		b \
		c;
	u=${1%.git};
	b=${2%/};
	c=${3:-null};

	b=${b#/};
	u=$u.git;

	\gcheck isGit ||
		\die "latchkey ring not forged";

	\gcheck "isValidUri" "$u" || {
		if
			\gcheck isValidUri "${u%.git}";
		then
			u=${u%.git};
		else
			\die "URI is not valid: '$u'";
		fi;
	};

	\gcheck "isValidBranchFormat" "$b" ||
		\die "latchkey name is not valid: '$b'";

	if
		\gcheck isBranch "$b";
	then
		\die "latchkey already hammered: '$b'";
	else
		\msg "hammering latchkey '$b' ...";
		\gbranch add "$b" "hammer latchkey $b";
		\msg "forging latchkey '$b' ...";
		\skel latchkey;
		\_fadd > ./LINFO;
		\gcommit "forge latchkey $b";
		\msg "forging latchkey ring ...";
		\gcheckout master;
		\_fadd >> ./LINFO;
		command sort -u -o ./LINFO ./LINFO;
		\gcommit "forge latchkey ring; after addition";
	fi;
}

forge__commit ()
{
	gcheck isGit ||
		die "latchkey ring not forged";

	local \
		_b \
		_c \
		_u \
		b;

	b=$(\gget currentBranch);

	if
		test "$b" = master;
	then
		\msg "forging latchkey ring ...";
		\gcommit "forge latchkey ring" || :;
	else
		if
			\gcheck isChanged "$myKeyRing/LINFO";
		then
			\msg "forging latchkey '$b' ...";
			\gcommit "forge latchkey '$b'" || :;
		else
			IFS='|' read -r _b _u _c < "./LINFO" || :;
			\msg "forging latchkey '$b' ...";
			\gcommit "forge latchkey '$b'" || :;
			\gcheckout master;
			local script1 script2;
			script1=$(
				echo "$b|[^|]*|[^|]*" |
				command sed -e 's|/|\\/|g';
			);
			script2=$(
				echo "$_b|$_u|$_c" |
				command sed -e 's|/|\\/|g';
			);
			command ed -s "$myKeyRing/LINFO" <<-S
				1,\$ s/^$script1\$/$script2/
				w
			S
			\msg "forging latchkey ring ...";
			\gcommit "forge latchkey ring" || :;
			\msg "switching back to '$b' ...";
			\gcheckout "$b";
		fi
	fi
}

forge__remove () {

	local  \
		_r \
		b=;
	b=${1%/};
	b=${b#/};

	\gcheck isGit ||
		\die "latchkey ring not forged";

	if
		\gcheck isBranch "$b";
	then
		\gcheckout "$b";
		\gclean;
		\msg "destroying latchkey '$b' ...";
		\gbranch "delete" "$b";
		\msg "forging latchkey ring ...";
		command ed -s "$myKeyRing/LINFO" <<-S
			g/^$(echo "$b|[^|]*|[^|]*" | command sed -e 's|/|\\/|g')\$/d
			w
		S
		\gcommit "forge latchkey ring; after deletion";
	else
		\die "latchkey has not been hammered: '$b'";
	fi;
}

forge__ring ()
if
	\gcheck isGit;
then
	\die "latchkey ring already hammered";
else
	\msg "hammering latchkey ring ...";
	\ginit "hammer latchkey ring";
	\msg "forging latchkey ring ...";
	printf '%s' "" > ./LINFO;
	\gcommit "forge latchkey ring; after initialization";
fi

forge__main ()
(
	test "$(idu)" -eq 0 &&
		\die "may not run as superuser";

	\import git;

	eval set -- "$myArgs";

	c=$1;
	shift 1;

	cd -- "$myKeyRing";

	export \
		GIT_DIR \
		GIT_WORK_TREE;
	GIT_DIR=$myKeyRing/.git \
	GIT_WORK_TREE=$myKeyRing;

	case $c in
		({})
			\die "unknown argument: '$c'";
		;;
		()
			"forge__$c" "$@";
	esac
)

# vim: set ft=sh :
