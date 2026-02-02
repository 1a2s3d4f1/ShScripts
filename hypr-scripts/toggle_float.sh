#!/bin/sh

#There are some modifies in this scripts.  And source from here:https://github.com/hyprwm/Hyprland/issues/2061#issuecomment-2558223661
active_workspace="$(hyprctl activewindow -j | jq -r ".workspace.id")"
if [ "$active_workspace" = "null" ]; then exit; fi

previous_client="$(hyprctl clients -j | jq -r '.[] | select(.workspace.id == '"$active_workspace"') | "dispatch togglefloating address:\(.address);"')"
if [ "$previous_client" = "null" ]; then exit; fi

hyprctl --batch "$previous_client"
