#!/usr/bin/awk -f

function check() {
        if (! length(Args["a"])) {
                die("latch/awk/error: action missing")
        }
}

function expandAction(      a, _v) {
        a = Args["a"];

        for (_v in _Vcs) {
                if (("DEFAULT", _v "_" a) in Config) {
                        if (! length(Config["DEFAULT", _v "_" a])) {
                                die("latch/awk/error: the DEFAULT section has set an empty value for: " _v "_" a)
                        }
                } else {
                        die("latch/awk/error: the DEFAULT section has not set a property for: " _v "_" a)
                }
        }
}

function _getopt(argc, argv, opts,      myOpt, i) {
        if (! length(opts)) {
                die("latch/awk/error: missing options")
        };

        if (argv[Optind] == "--") {
                Optind++;
                _opti = 0;
                return -1
        } else if (argv[Optind] !~ /^-[^: \t\r\n\013\f\b\007]/) {
                _opti = 0;
                return -1
        };

        if (_opti == 0) {
                _opti = 2
        };

        myOpt = substr(argv[Optind], _opti, 1);
        i = index(opts, myOpt);

        if (i == 0) {
                die("latch/awk/error: invalid option: " myOpt)
        };

        if (substr(opts, i + 1, 1) == ":") {
                if (length(substr(argv[Optind], _opti + 1)) > 0) {
                        Optarg = substr(argv[Optind], _opti + 1)
                } else {
                        Optarg = argv[++Optind]
                };
                _opti = 0
        } else {
                Optarg = ""
        };

        if (_opti == 0 || _opti >= length(argv[Optind])) {
                Optind++;
                _opti = 0
        } else {
                _opti++
        };

        return myOpt
}

function getopt(    opt) {
        Optind = 1;
        Optarg = "";
        _opti = 0;
        opt = "";

        while ((opt = _getopt(ARGC, ARGV, "a:")) != -1) {
                if (opt == "a" && ! length(Optarg)) {
                        die("latch/awk/error: argument missing: " opt)
                } else {
                        Args[opt] = Optarg
                }
        }
}

function selectRepos(       a, m, _v, v) {
        a = Args["a"];

        for (m in Mirrors) {
                if (m == "DEFAULT") {
                        continue
                };

                for (_v in _Vcs) {
                        if (match(m, "\." _v "$")) {
                                v = _v;
                                break
                        }
                };

                if (! length(v)) {
                        die("latch/awk/error: section name points probably not to a vcs repo: " m)
                };

                if ((m, a) in Config) {
                        printf("%s %s\n", quote(m), quote(Config[m, a]))
                } else {
                        printf("%s %s\n", quote(m), quote(Config["DEFAULT", v "_" a]))
                }
        }
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

        split("", Args);
        split("", Config);
        split("", Mirrors);

        getopt();
        check();
        loadConfig();
        expandAction();
        selectRepos()
}

# vim: set ts=8 sw=8 tw=0 et :
