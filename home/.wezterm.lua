local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- config.color_scheme = 'Spacegray (Gogh)'
config.color_scheme = 'Nord (Gogh)'
-- config.color_scheme = 'Tokyo Night (Gogh)'
-- config.color_scheme = 'Tokyo Night Storm (Gogh)'
-- Since: Version nightly builds only
-- config.color_scheme = 'Iceberg (Gogh)'

config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = '#3B4252',
      fg_color = '#A3BE8C',
    },
  }
}

config.font = wezterm.font('HackGen Console NF')
config.font_size = 16

config.default_cursor_style = 'SteadyBar'
config.audible_bell = 'Disabled'
config.automatically_reload_config = true
config.scrollback_lines = 100000
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"

-- https://wezfurlong.org/wezterm/config/default-keys.html
-- SUPER+t: SpawnTab="CurrentPaneDomain"
-- SUPER+w: CloseCurrentTab{confirm=true}
-- SUPER+1: ActivateTab=1
-- SUPER+2: ActivateTab=2
-- CTRL+SHIFT+P: ActivateCommandPalette
-- SUPER+f: Search={CaseSensitiveString=""}
config.leader = { key = 'g', mods = 'CTRL', timeout_milliseconds = 1000 }
local act = wezterm.action
config.keys = {
  -- https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
  { key = '[',     mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = ']',     mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = '{',     mods = 'LEADER', action = act.MoveTabRelative(-1) },
  { key = '}',     mods = 'LEADER', action = act.MoveTabRelative(1) },
  -- https://wezfurlong.org/wezterm/copymode.html
  { key = 'c',     mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 's',     mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'v',     mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'h',     mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'l',     mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'j',     mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k',     mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'Space', mods = 'LEADER', action = act.RotatePanes 'Clockwise' },
  { key = 'z',     mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'p',     mods = 'LEADER', action = act.ScrollToPrompt(-1) },
  { key = 'n',     mods = 'LEADER', action = act.ScrollToPrompt(1) },
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'resize_pane_mode',
      one_shot = false,
    },
  },
}

local copy_mode = wezterm.gui.default_key_tables().copy_mode
table.insert(
  copy_mode,
  { key = 'v', mods = 'ALT', action = act.CopyMode { SetSelectionMode = 'SemanticZone' } }
)
table.insert( -- search modeに遷移
  copy_mode,
  { key = '/', mods = 'NONE', action = act.CopyMode 'EditPattern' }
)

local search_mode = wezterm.gui.default_key_tables().search_mode
table.insert( -- copy modeに戻る
  search_mode,
  { key = 'Enter', mods = 'NONE', action = act.CopyMode 'AcceptPattern' }
)

config.key_tables = {
  copy_mode = copy_mode,
  search_mode = search_mode,
  resize_pane_mode = {
    { key = 'h',      action = act.AdjustPaneSize { 'Left', 10 } },
    { key = 'l',      action = act.AdjustPaneSize { 'Right', 10 } },
    { key = 'j',      action = act.AdjustPaneSize { 'Down', 10 } },
    { key = 'k',      action = act.AdjustPaneSize { 'Up', 10 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'q',      action = 'PopKeyTable' },
  },
}

return config
