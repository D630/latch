#!/usr/bin/env sh

punregister ()
{
        case "$1" in
        pkg)
                command ed -s "$myPkgList" <<S
g/^$(echo "${PKG_NAME}|${DISTDIR_DESC}|${KEY_DESC}|${myContext}|0" | command sed -e 's|/|\\/|g')$/d
w
S
        ;;
        stow)
                command ed -s "$myPkgList" <<S
1,$s /^$(echo "\(${PKG_NAME}|[^|]*|[^|]*|${myContext}|\)1" | command sed -e 's|/|\\/|g')$/\10/
w
S
        ;;
        *)
                die "latch/pkg/punregister/error: unknown argument -? ${1}"
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
