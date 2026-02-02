#!/bin/sh
use_floating_layout () {
hyprctl keyword 'windowrule[float-mode]:enable true'
touch "$XDG_RUNTIME_DIR"/hypr-float.lock
notify-send -e -a HyprFloatMode -i ~/.config/hypr/assets/float.png -u low 'Window layout' 'Toggle floating layout';
sh ~/.config/hypr/scripts/toggle_float.sh
}

use_default_layout () {
hyprctl keyword 'windowrule[float-mode]:enable false'
rm "$XDG_RUNTIME_DIR"/hypr-float.lock
notify-send -e -a HyprFloatMode -i ~/.config/hypr/assets/tile.png -u low 'Window layout' 'Toggle tiling layout';
sh ~/.config/hypr/scripts/toggle_float.sh
}

find "$XDG_RUNTIME_DIR"/hypr-float.lock
    case $? in
        0)use_default_layout;;
        1)use_floating_layout;;
    esac
