#!/usr/bin/env sh

__plimit ()
{
        if
                [ "$arePacked" -gt 1 ]
        then
                _l="${_l} chop"
        else
                :
        fi
}

_plimit ()
if
        ! [ "$stowedIs" = "null" ]
then
        case "$myPkgAction" in
        purge)
                die "current stowed version must be unstowed: '${stowedIs}'"
        esac
        __plimit
else
        :
fi

plimit ()
{
        local _l

        case "${isInitialized}::${isPacked}::${isStowed}" in
        false::*)
                _l="init build"
        ;;
        true::false::*)
                _l="purge build install"
                _plimit
        ;;
        true::true::false)
                _l="purge build remove"
                _plimit
        ;;
        true::true::true)
                _l="build"
                __plimit
        esac

        if
            test "${_l:-_}" = "_"
        then
            die "alarm. something went wrong, really"
        else
            _l=" $_l "
        fi

        msg "{${_l}}"

        case "$_l" in
        *" ${myPkgAction} "*)
                :
        ;;
        *)
                die "myPkgAction cannot be executed: '${myPkgAction}'"
        esac
}

# vim: set ts=8 sw=8 tw=0 et :
