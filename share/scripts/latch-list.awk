#!/usr/bin/mawk -f

function replace(str) {
        gsub(/\//, "::", str);
        return str
}

function build(     b,c,d,u,cmd) {
        while ((getline u < "/home/latch/var/UPDATES") > 0) {
                Src[replace(u), "u"]++
        };

        close("/home/latch/var/UPDATES");

        cmd = "cat /home/latch/var/pkg.list";

        FS = "|";

        while ((cmd | getline) > 0) {
                Src[$1, "n"] = 1;
                Src[$1, "b"]++
                Src[$1, "c"] = $4
                if ($5 == 1) {
                        Src[$1, "s"]++
                }
        };

        close(cmd)
}

function output(    _s, s) {
        print "N|C|P|S|U";
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
