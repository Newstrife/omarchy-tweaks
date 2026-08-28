# omarchy-tweaks

个人 [Omarchy](https://omarchy.org/)（Hyprland）配置调整集合。

## 内容

### 1. 触摸板滚动速度修复（`hypr/input.lua`）

双指滚动速度过快，将 `scroll_factor` 从 `2.5` 调整为 `1.0`（Hyprland 默认值）。

> 注意：`scroll_factor` 只控制触摸板滚动速度，与鼠标指针速度（`sensitivity`）是相互独立的设置。

### 2. Windows 风格 ALT+TAB 应用切换器（`hypr/bindings.lua`）

替换 Omarchy 默认的 ALT+TAB（仅切换焦点），实现：

- **按住 ALT 连续按 TAB**：在快照固定的窗口列表中**顺序前进**，可循环到达当前工作区的每一个应用（按最近使用顺序），不会在两个应用间来回弹
- **ALT + SHIFT + TAB**：反方向切换
- 切换目标应用**最大化显示**（`fullscreen_state` SET 语义），上一个窗口的最大化/全屏状态自动还原
- 仅在**当前工作区**内切换，不跳转其他页面
- 会话在最后一次按键 1 秒后过期（`hl.timer` 超时单位是**毫秒**）

### 快捷键总览

| 按键 | 功能 |
|------|------|
| `ALT + TAB` | 下一个应用（最大化显示） |
| `ALT + SHIFT + TAB` | 上一个应用 |
| `SUPER + LEFT / RIGHT` | 上/下一个工作区 |
| 三指左右滑动 | 上/下一个工作区 |
| 四指上滑 | Omarchy 菜单 |
| 四指下滑 | Scratchpad |

## 安装

```bash
git clone https://github.com/Newstrife/omarchy-tweaks.git
cp omarchy-tweaks/hypr/input.lua ~/.config/hypr/
cp omarchy-tweaks/hypr/bindings.lua ~/.config/hypr/
hyprctl reload
```

## 环境

- Omarchy（Hyprland 0.56+，Lua 配置）
- 验证配置：`hyprctl reload && hyprctl configerrors`
- 查看当前快捷键：`omarchy menu keybindings --print`
