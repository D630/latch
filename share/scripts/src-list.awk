#!/usr/bin/mawk -f

function basename(str) {
        sub(/^.*\//, "", str);
        return str
}

function dirname(str) {
        sub(/\/[^\/]*$/, "", str);
        return str
}

function trim(str) {
        sub(/^\.\//, "", str);
        return str
}

function replace(str) {
        gsub(/\//, "::", str);
        return str
}

function build(     b,c,d,u,cmd) {
        while ((getline u < "/home/src/mr/UPDATES") > 0) {
                Src[replace(u), "u"]++
        };

        close("/home/src/mr/UPDATES");

        cmd = "cd -- /home/src/mr ; LC_COLLATE=C find . ! -path '*/.*/*' -type f \\( -name SCONTEXT -o -name '*.branch' -o -name '*.stowed' \\)";

        while ((cmd | getline l) > 0) {
                d = replace(dirname(trim(l)));
                b = basename(l);
                Src[d, "n"] = 1;
                if (b ~ /.*\.branch$/) {
                        Src[d, "b"]++
                } else if (b ~ /.*\.stowed$/) {
                        Src[d, "s"]++
                } else if (b == "SCONTEXT") {
                        if ((getline c < ("/home/src/mr/" l)) > 0) {
                                Src[d, "c"] = c
                        } else {
                                Src[d, "c"] = "?"
                        };
                        close("/home/src/mr/" l)
                }
        };

        close(cmd)
}

function output(    _s, s) {
        print "N|C|R|S|U";
        for (_s in Src) {
                if (_s ~ /\|n$/) {
                        split(_s, s, SUBSEP);
                        printf("%s|%s|%d|%d|%d\n",
                                        s[1],
                                        Src[s[1],"c"],
                                        Src[s[1],"b"],
                                        Src[s[1],"s"],
                                        Src[s[1],"u"] \
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

# vim: set ts=8 sw=8 tw=0 et :
