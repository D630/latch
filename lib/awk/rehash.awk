#!/usr/bin/awk -f

function loadRemotes() {
	FS = "|";

	while ((getline < myLInfo) > 0) {
		Remotes[$1] = $2
	};

	close(myLInfo);

	if (isEmptyArr(Remotes)) {
		die("latch/awk/error: LINFO file is empty")
	}
}

function mergeRemotes(    r) {
	for (r in Remotes) {
		Mirrors[r ".git"] = 1;
		Config[r ".git", "mirror"] = sprintf("git_mirror '%s' '%s.git'", Remotes[r], basename(r))
	}
}

function printConfig(    _) {
	getline _ < myMirrorList;

	printf("#!/usr/bin/awk -f\n\nBEGIN {\n\tFS = \" \";\n\tRS = \"\\n\";\n\tSUBSEP = \"\\034\";\n\tsplit(\"\", _Mirrors);\n\tsplit(\"\", _Vcs);\n\n") > myMirrorList;
	printVcs();
	printMirrors();
	printf("# vim: set ts=8 sw=8 tw=0 et :\n") >> myMirrorList;

	close(myMirrorList)
}

function printMirrors(    _c, _i, _m, c, i, m) {
	printf("\t_Mirrors[ \\\n") >> myMirrorList;

	for (m in Mirrors) {
		_m++
	}

	for (m in Mirrors) {
		i++;
		_i = 1;
		if (i == 1) {
			printf("\t\t\"- name:\t%s\",\n", m) >> myMirrorList
		} else {
			printf("\n\t\t\"- name:\t%s\",\n", m) >> myMirrorList
		};
		for (c in Config) {
			if (match(c, "^" m SUBSEP)) {
				split(c, _c, SUBSEP);
				if (i == _m && _i == Mirrors[m]) {
					printf("\t\t\"\t%s:\t%s\" \\\n", _c[2], Config[c]) >> myMirrorList
				} else {
					printf("\t\t\"\t%s:\t%s\",\n", _c[2], Config[c]) >> myMirrorList
				};
				_i++
			}
		}
	};

	printf("\t]++\n}\n\n") >> myMirrorList
}

function printVcs(    v) {
	for (v in _Vcs) {
		printf("\t_Vcs[\"%s\"]++;\n", v) >> myMirrorList
	};

	print "" >> myMirrorList
}

BEGIN {
	if (isEmptyArr(_Vcs)) {
		msg("latch/awk/error: mirror.list is not valid");
		die("latch/awk/error: _Vcs array is empty")
	};

	if (isEmptyArr(_Mirrors)) {
		msg("latch/awk/error: mirror.list is not valid");
		die("latch/awk/error: _Mirrors array is empty")
	};

	split("", Config);
	split("", Mirrors);
	split("", Remotes);
	myRoot = ENVIRON["myRoot"];
	myMirrorList = ENVIRON["myMirrorList"];
	myLInfo = ENVIRON["myLInfo"];

	loadRemotes();
	loadConfig();
	mergeRemotes();
	printConfig()
}

# vim: set ft=awk :
