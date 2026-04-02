## 用于 hyprland 的脚本

### hypr-minimize.sh

> 注意：需要 jq 与 wofi

![minimize-gif](imgs/hypr-minimize.gif)

用于最小化或还原最小化窗口的 shell 脚本。

使用：hypr-minimize.sh \<options\>

选项
-m 最小化一个活动窗口。

-r 打开 wofi dmenu 以选择要恢复的窗口

-g 获取特殊工作区的窗口数量。

### HyprMinimizeHelper

用于处理被状态栏应用（例如 waybar）发出的最小化事件或窗口活动事件。

使用：应该在 hyprland 启动后启动，例如：`exec-once = ~/.config/hypr/scripts/HyprMinimizeHelper.sh`

### HyprFloatMode.sh

用于在 hyprland 中临时切换到 shell脚本。

### window-selector.sh

用于切换窗口的 Shell 脚本,使用方法：window-selector.sh \<option\>

选项：`-switch` 在当前工作区切换窗口

`-select` 打开 wofi dmenu 界面选择窗口

### hyprXresources.sh

用于自动配置 Xresources 的 shell 脚本。

用法：直接执行即可
