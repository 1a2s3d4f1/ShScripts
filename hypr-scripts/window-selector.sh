#!/bin/sh
switch_windows(){
#There are some modifies in this scripts.  And source from here:https://github.com/hyprwm/Hyprland/issues/2061#issuecomment-2558223661
active_workspace="$(hyprctl activewindow -j | jq -r ".workspace.id")"
if [ ! "$active_workspace" ]; then exit; fi
previous_client="$(hyprctl clients -j | jq -r '[.[] | select(.workspace.id == '"$active_workspace"')] | sort_by(.focusHistoryID) | last | .address')"
if [ ! "$previous_client" ]; then exit; fi
hyprctl --batch "dispatch focuswindow address:$previous_client; dispatch alterzorder top"
}
choose_windows(){
#from here (https://with9.github.io/post/hyprland-wofi/)
    win_addr=$(hyprctl clients -j | jq -r '.[] | select(.title != "") | "\(.address)[\(.workspace.id)]  \(.title)@\(.class)"'|wofi --show dmenu -i -M fuzzy |cut -f1 -d\[|head -1)
    #-i  mean case insensitive; -M fuzzy mean fuzzy search
    if echo "$win_addr" | grep -n ^0x >/dev/null
    then
        hyprctl dispatch focuswindow address:"$win_addr";
        hyprctl dispatch alterzorder top,address:"$win_addr";
    fi
}
    case $1 in
   -switch*)switch_windows;;
   -select*)choose_windows;;
   *)printf "Usage: window-selector.sh <option> \navailable options: -switch Switch window from current workspace，-select open wofi menu for choose window";;
    esac
