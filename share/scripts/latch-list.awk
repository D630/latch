#!/usr/bin/mawk -f

function replace(str) {
	gsub(/\//, "::", str);
	return str
}

function build(    b,c,d,u,cmd) {
	cmd = "cat /home/latch/var/pkg.list";

	FS = "|";

	while ((cmd | getline) > 0) {
		Src[$1, "n"] = 1;
		Src[$1, "b"]++
		Src[$1, "c"] = $5
		if ($6 == 1) {
			Src[$1, "s"]++
		}
	};

	close(cmd)
}

function output(    _s, s) {
	print "N|C|P|S";
	for (_s in Src) {
		if (_s ~ /\|n$/) {
			split(_s, s, SUBSEP);
			printf("%s|%s|%d|%d\n",
			   s[1],
			   Src[s[1],"c"],
			   Src[s[1],"b"],
			   Src[s[1],"s"] \
			)
		}
	}
}

BEGIN {
	SUBSEP = "|";
	split("", Src);
	build();
	output();
}

# vim: set ft=awk :
