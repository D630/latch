#!/usr/bin/env sh

sunstow ()
{
        command xstow -v 3 \
                -F "$myXstowConfig" \
                -dir "$STOW_DIR" \
                -target "$STOW_TARGET" \
                -D "${1:-$PKG_NAME}";
}

# vim: set ts=8 sw=8 tw=0 et :
