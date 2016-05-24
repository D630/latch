#!/usr/bin/env sh

sstow ()
{
        command xstow -v 3 \
                -F "$myXstowConfig" \
                -dir "$STOW_DIR" \
                -target "$STOW_TARGET" \
                "${1:-$PKG_NAME}";
}

# vim: set ts=8 sw=8 tw=0 et :
