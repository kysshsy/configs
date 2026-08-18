local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

config.color_scheme = 'Dracula+'

-- set font
config.font = wezterm.font('DejaVu Sans Mono',{})

-- macOS already has native Cmd+T/W and Cmd+1..8 bindings. On Linux Toshy
-- reserves Ctrl+Alt+1..8 as the destination for a real Cmd+number. Ctrl+Shift
-- is intentionally avoided because Fcitx/Rime uses it for input toggles.
if not wezterm.target_triple:find('apple%-darwin') then
  config.keys = {}
  for i = 1, 8 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL',
      action = act.DisableDefaultAssignment,
    })
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL|ALT',
      action = act.ActivateTab(i - 1),
    })
  end
end


return config
