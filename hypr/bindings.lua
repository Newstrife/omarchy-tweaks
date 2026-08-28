-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Touchpad gestures (requires Hyprland 0.40+, currently on 0.56.2)
-- Three-finger swipe left/right → switch to previous/next workspace
o.bind("mouse:gesture:3:right", "Next workspace (gesture)", hl.dsp.focus({ workspace = "e+1" }))
o.bind("mouse:gesture:3:left", "Previous workspace (gesture)", hl.dsp.focus({ workspace = "e-1" }))

-- Four-finger swipe up/down → open Omarchy menu / toggle scratchpad
o.bind("mouse:gesture:4:up", "Omarchy menu (gesture)", "omarchy-menu toggle root")
o.bind("mouse:gesture:4:down", "Toggle scratchpad (gesture)", hl.dsp.workspace.toggle_special("scratchpad"))

-- Super + Left/Right → switch workspaces (replaces focus window)
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
o.bind("SUPER + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- ALT+TAB: Windows-style app switcher for the CURRENT workspace (no page
-- switching). While ALT is held, each TAB press advances sequentially through
-- a snapshot of the window stack (MRU order), so you can reach every app.
-- The chosen window is shown maximized; the previous one is restored.
-- ALT+SHIFT+TAB cycles the opposite direction.
local switch_session = nil -- { list = {...}, idx = n } snapshot while ALT held
local session_timer = nil

local function app_switch(previous)
  local active = hl.get_active_window()
  local ws = hl.get_active_workspace()

  -- New session (first TAB press): snapshot the current MRU order so repeated
  -- presses walk the SAME list instead of bouncing between two windows.
  if not switch_session then
    local wins = {}
    for _, w in ipairs(hl.get_windows()) do
      if w.mapped and w.workspace and not w.workspace.special
         and ws and w.workspace.id == ws.id then
        table.insert(wins, w)
      end
    end
    table.sort(wins, function(a, b) return a.focus_history_id < b.focus_history_id end)

    -- Position of the currently active window in the snapshot
    local idx = 0
    if active then
      for i, w in ipairs(wins) do
        if w.address == active.address then idx = i break end
      end
    end
    switch_session = { list = wins, idx = idx }
  end

  local s = switch_session
  local n = #s.list
  if n == 0 then switch_session = nil return end

  -- Advance (wraps around at both ends)
  if previous then
    s.idx = ((s.idx - 2) % n) + 1
  else
    s.idx = (s.idx % n) + 1
  end
  local target = s.list[s.idx]
  if not target then switch_session = nil return end

  -- Restore the window we're leaving (if it was maximized/fullscreen)
  local cur = hl.get_active_window()
  if cur and cur.address ~= target.address and (cur.fullscreen or 0) ~= 0 then
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, window = cur }))
  end

  hl.dispatch(hl.dsp.focus({ window = target }))
  hl.dispatch(hl.dsp.window.bring_to_top())
  hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 1, client = 1, window = target }))

  -- Keep the session alive while ALT stays held (expires 1s after the last TAB)
  if session_timer then session_timer:set_enabled(false) end
  session_timer = hl.timer(function() switch_session = nil end, { timeout = 1000, type = "oneshot" })
end

-- Replace the default ALT+TAB bindings (which only changed focus)
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")
o.bind("ALT + TAB", "Next app (maximized)", function() app_switch(false) end)
o.bind("ALT + SHIFT + TAB", "Previous app (maximized)", function() app_switch(true) end)
