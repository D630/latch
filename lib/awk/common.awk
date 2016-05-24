#!/usr/bin/awk -f

function basename(str) {
        sub(/^.*\//, "", str);
        return str
}

function die(str) {
        msg(str);
        exit 1
}

function isEmptyArr(arr,      idx) {
        for (idx in arr) {
                return 0
        };
        return 1
}

function getKey(str) {
        str = trim(str);
        str = substr(str, 1, index(str, ":") - 1);
        return str
}

function getVal(str) {
        sub(/^[^:]*:/, "", str);
        str = trim(str);
        return str
}

function loadConfig(    _i, _m, _n, m, s) {
        for (_m in _Mirrors) {
                _n = split(_m, m, SUBSEP);
                for (_i = 1; _i <= _n; ++_i) {
                        if (match(m[_i], "^- name:[ \t\r\n\013\f\b\007]+[^ \t\r\n\013\f\b\007]+$")) {
                                s = substr(m[_i], 8, length(m[_i]) - 7);
                                gsub(/[ \t\r\n\013\f\b\007]*/, "", s)
                        } else if (match(m[_i], "^  [^: \t\r\n\013\f\b\007]+:[ \t\r\n\013\f\b\007]+.+$")) {
                                # TODO
                                if (! length(s)) {
                                        die("latch/awk/error: Could not found a section name for: " m[_i])
                                };
                                Config[s,getKey(m[_i])] = getVal(m[_i]);
                                Mirrors[s]++
                        }
                }
        };
}

function msg(str) {
        printf("%s\n", str) > "/dev/stderr"
}

function quote(str) {
        gsub(/'/, "'\\''", str);
        return sprintf("'%s'", str)
}

function trim(str) {
        sub(/^[ \t\r\n\013\f\b\007]*/, "", str);
        return str
}

# vim: set ts=8 sw=8 tw=0 et :
