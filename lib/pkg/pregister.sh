#!/usr/bin/env sh

pregister ()
{
        case "$1" in
        pkg)
                printf '%s|%s|%s|%s|%d\n' \
                        "$PKG_NAME" \
                        "$DISTDIR_DESC" \
                        "$KEY_DESC" \
                        "$myContext" \
                        "0" \
                >> "$myPkgList";
        ;;
        stow)
                command ed -s "$myPkgList" <<S
1,$s /^$(echo "\(${PKG_NAME}|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|\)0" | command sed -e 's|/|\\/|g')$/\11/
w
S
        ;;
        *)
                die "latch/pkg/pregister/error: unknown argument -? ${1}"
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
