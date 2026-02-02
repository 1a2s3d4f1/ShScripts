#!/bin/sh

minimize_window () {
  move_window() {
    hyprctl dispatch movetoworkspace "$act_workspace",address:"$win_addr";
  }
  alter_z_order () {
    hyprctl dispatch alterzorder top,address:"$win_addr";
  }
  win_addr=0x"$(echo "$1" | cut -d '>' -f3 | cut -d ',' -f1)";
  act_win_addr=$(hyprctl activewindow -j | jq -r '.address');
  act_workspace=$(hyprctl activeworkspace -j | jq '.id');
  min_window_list=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized") | "\(.address)"');

  if echo "$act_win_addr" | grep "$win_addr" > /dev/null
  then if  echo "$min_window_list" | grep "$win_addr" > /dev/null
    then
    move_window;
    alter_z_order;
    else
    hyprctl dispatch  movetoworkspacesilent special:minimized,address:"$win_addr";
    fi
    return 0;
  fi

  if echo "$min_window_list" | grep "$win_addr" > /dev/null
  then
    move_window;
    alter_z_order;
  else
    hyprctl dispatch focuswindow address:"$win_addr";
    alter_z_order;
  fi
  return 0;
}

handle_active_window () {
  win_addr=$(echo "$1" | cut -d '>' -f3);
  min_window_list=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized") | "\(.address)"');
  act_workspace=$(hyprctl activeworkspace -j | jq '.id');
  if  echo "$min_window_list" | grep "$win_addr" > /dev/null
  then
    hyprctl dispatch movetoworkspace "$act_workspace",address:0x"$win_addr";
    hyprctl dispatch alterzorder top,address:0x"$win_addr";
  fi
}

handle() {
  case $1 in
    minimized*) minimize_window "$1";;
    activewindowv2*) handle_active_window "$1";;
  esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | while read -r line; do handle "$line"; done
