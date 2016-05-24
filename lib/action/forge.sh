#!/usr/bin/env sh

forge_action ()
(
        import \
                forge \
                git;

        eval set -- "$myArgs"

        c="$1"
        shift 1

        cd -- "$myKeyRing"

        case "$c" in
        {})
                die "latch/forge/error: unknown argument -? '${c}'"
        ;;
        *)
                "f${c}" "$@"
        esac

        msg "latch/forge: DONE"
)

# vim: set ts=8 sw=8 tw=0 et :
