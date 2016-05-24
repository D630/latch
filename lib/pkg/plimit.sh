#!/usr/bin/env sh

_plimit ()
if
        [ "$stowedIs" != "<>" -a "$arePacked" -gt 1 ]
then
        _l="${_l} chop"
fi

plimit ()
{
        local _l

        case "${isInitialized}::${isPacked}::${isStowed}" in
        false::false::false)
                _l="init"
        ;;
        true::false::false)
                _l="install purge"
                _plimit
        ;;
        true::true::false)
                _l="purge remove stow"
                _plimit
        ;;
        true::true::true)
                _l="purge remove unstow"
                _plimit
        esac

        if
                [ "${_l:-_}" = "_" ]
        then
                die "latch/pkg/plimit/error: Something went wrong, really"
        else
                _l=" ${_l} info "
        fi

        msg "latch/pkg/plimit: {${_l:-' ? '}}"

        case "$_l" in
        *" ${myPkgAction} "*)
                if
                        [ "$myPkgAction" = "stow" -a "$stowedIs" != "<>" ]
                then
                        die "latch/pkg/plimit/error: Current version must be unstowed: '${stowedIs}'"
                fi
        ;;
        *)
                die "latch/pkg/plimit/error: damn, myPkgAction cannot be executed"
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
