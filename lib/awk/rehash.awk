#!/usr/bin/awk -f

function loadRemotes() {
        while ((getline < myLRemote) > 0) {
                gsub(/'/, "", $0);
                Remotes[$1] = $2
        };

        close(myLRemote);

        if (isEmptyArr(Remotes)) {
                die("latch/awk/error: LREMOTE file is empty")
        }
}

function mergeRemotes(      r) {
        for (r in Remotes) {
                if (match(r, "/m$")) {
                        Mirrors[Remotes[r]] = 1;
                        Config[Remotes[r], "mirror"] = sprintf("git_mirror_mirror '%s' '%s'", Remotes[trimType(r, "m") "/u"], basename(Remotes[r]))
                }
        }
}

function printConfig(       _) {
        getline _ < mySrcList;

        printf("#!/usr/bin/awk -f\n\nBEGIN {\n\tFS = \" \";\n\tRS = \"\\n\";\n\tSUBSEP = \"\\034\";\n\tsplit(\"\", _Mirrors);\n\tsplit(\"\", _Vcs);\n\n") > mySrcList;
        printVcs();
        printMirrors();
        printf("# vim: set ts=8 sw=8 tw=0 et :\n") >> mySrcList;

        close(mySrcList)
}

function printMirrors(      _c, _i, _m, c, i, m) {
        printf("\t_Mirrors[ \\\n") >> mySrcList;

        for (m in Mirrors) {
                _m++
        }

        for (m in Mirrors) {
                i++;
                _i = 1;
                if (i == 1) {
                        printf("\t\t\"- name:\t%s\",\n", m) >> mySrcList
                } else {
                        printf("\n\t\t\"- name:\t%s\",\n", m) >> mySrcList
                };
                for (c in Config) {
                        if (match(c, "^" m SUBSEP)) {
                                split(c, _c, SUBSEP);
                                if (i == _m && _i == Mirrors[m]) {
                                        printf("\t\t\"  %s:\t%s\" \\\n", _c[2], Config[c]) >> mySrcList
                                } else {
                                        printf("\t\t\"  %s:\t%s\",\n", _c[2], Config[c]) >> mySrcList
                                };
                                _i++
                        }
                }
        };

        printf("\t]++\n}\n\n") >> mySrcList
}

function printVcs(      v) {
        for (v in _Vcs) {
                printf("\t_Vcs[\"%s\"]++;\n", v) >> mySrcList
        };

        print "" >> mySrcList
}

function trimType(str,t,    re) {
        re = ("/" t "$");
        sub(re, "", str);
        return str
}

BEGIN {
        if (isEmptyArr(_Vcs)) {
                msg("latch/awk/error: src.list is not valid");
                die("latch/awk/error: _Vcs array is empty")
        };

        if (isEmptyArr(_Mirrors)) {
                msg("latch/awk/error: src.list is not valid");
                die("latch/awk/error: _Mirrors array is empty")
        };

        split("", Config);
        split("", Mirrors);
        split("", Remotes);
        myRoot = ENVIRON["myRoot"];
        mySrcList = ENVIRON["mySrcList"];
        myLRemote = ENVIRON["myLRemote"];

        loadRemotes();
        loadConfig();
        mergeRemotes();
        printConfig()
}

# vim: set ts=8 sw=8 tw=0 et :
