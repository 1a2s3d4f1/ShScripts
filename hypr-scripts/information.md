## Scripts for hyprland

English | [中文](information_zh.md)

### hypr-minimize.sh
> note: jq and wofi are needed

![minimize-gif](imgs/hypr-minimize.gif)

A shell script used to minimize or recover a window.

Usage: hypr-minimize.sh \<options\> can be

`-m` minimize an activity window. 

`-r` open a wofi dmenu for choose window which should be recovered. 

`-g` get window count of special workspace.

### HyprMinimizeHelper

It is used to handle minimize event and window activity event whith is emitted by status bar application (e.g. waybar).

Usage: should be start when hyprland started. e.g. `exec-once = ~/.config/hypr/scripts/HyprMinimizeHelper.sh`

### HyprFloatMode.sh

A simple shell script to toggle window rule of hyprland.

### window-selector.sh

It is used to switch window in a workspace or select window which should been activity.

Usage: window-selector.sh \<option\> 

option: `-switch` Switch window in current workspace.

`-select` Open wofi dmenu for select window.

### hyprXresources.sh

A shell script used to configurate Xresources automatically.
Usage: just execute this script
