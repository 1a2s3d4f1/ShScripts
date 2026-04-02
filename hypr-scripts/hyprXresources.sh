#!/bin/sh
init () {
work_dir=$(mktemp -d)
}

get_current_scale () {
current_scale=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')
}

set_x11_dpi () {
x11_dpi=96
get_current_scale
xft_dpi=$(awk 'BEGIN{printf("%.f",'"$x11_dpi"*"$current_scale"')}')
echo "$current_scale" > "$work_dir/scale"
}

set_font_conf () {
fontconf_info=$(fc-match --verbose)
if echo "$fontconf_info" | grep antialias| grep True >/dev/null
then xft_antialias=1
else xft_antialias=0
fi

if echo "$fontconf_info" | grep hinting| grep True >/dev/null
then xft_hinting=1
else xft_hinting=0
fi

if echo "$fontconf_info" | grep hintstyle | grep 0 >/dev/null
then xft_hintstyle=hintnone
elif echo "$fontconf_info" | grep hintstyle | grep 1 >/dev/null
then xft_hintstyle=hintslight
elif echo "$fontconf_info" | grep hintstyle | grep 2 >/dev/null
then xft_hintstyle=hintmedium
elif echo "$fontconf_info" | grep hintstyle | grep 3 >/dev/null
then xft_hintstyle=hintfull
else xft_hintstyle=hintnone
fi

if echo "$fontconf_info" | grep rgba | grep 1 >/dev/null
then xft_rgba=rgb
elif echo "$fontconf_info" | grep rgba | grep 2 >/dev/null
then xft_rgba=bgr
elif echo "$fontconf_info" | grep rgba | grep 3 >/dev/null
then xft_rgba=vrgb
elif echo "$fontconf_info" | grep rgba | grep 4 >/dev/null
then xft_rgba=vbgr
elif echo "$fontconf_info" | grep rgba | grep 5 >/dev/null
then xft_rgba=none
else xft_rgba=none
fi
fontconf_info=1
}

merge_xresource () {
{
echo "Xft.antialias: $xft_antialias";
echo "Xft.dpi: $xft_dpi";
echo "Xft.hinting: $xft_hinting";
echo "Xft.hintstyle: $xft_hintstyle";
echo "Xft.rgba: $xft_rgba";
} > "$work_dir/Xresources"
xrdb -merge "$work_dir/Xresources"
}

init;
get_current_scale;
set_x11_dpi;
set_font_conf;
merge_xresource;

try_update () {
get_current_scale
if cat "$work_dir/scale" | grep "$current_scale"
then echo 1
else set_x11_dpi;
set_font_conf;
merge_xresource;
fi
}

handle() {
  case $1 in
    configreloaded*) try_update ;;
  esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
