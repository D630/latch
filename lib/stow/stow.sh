#!/usr/bin/env sh

slimit ()
{
        local _l
        _l=_

        case "${isInitialized}::${isPacked}::${isStowed}" in
        false::*)
                :
        ;;
        true::false::*)
                :
        ;;
        true::true::false)
                if
                        [ "$stowedIs" = "null" ]
                then
                        _l="add"
                else
                        _l="delete"
                fi
        ;;
        true::true::true)
                _l="delete"
        esac

        if
                [ "$_l" = "$myStowAction" ]
        then
                msg "{ ${_l} }"
        else
                die "myStowAction cannot be executed: '${myStowAction}'"
        fi
}

sstow ()
{
        command xstow -v 3 \
                -F "$myXstowConfig" \
                -dir "$STOW_DIR" \
                -target "$STOW_TARGET" \
                "${1:-$PKG_NAME}";
}

sunstow ()
{
        command xstow -v 3 \
                -F "$myXstowConfig" \
                -dir "$STOW_DIR" \
                -target "$STOW_TARGET" \
                -D "${1:-$PKG_NAME}";
}

# vim: set ts=8 sw=8 tw=0 et :
