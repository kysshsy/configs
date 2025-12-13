local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

config.color_scheme = 'Dracula+'

-- set font
config.font = wezterm.font('DejaVuSansMono',{})

config.keys = {
{
    key = 't',
    mods = 'ALT',
    action = act.SpawnTab 'CurrentPaneDomain',
},
{
    key = 'w',
    mods = 'ALT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
}
}
for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = act.ActivateTab(i - 1),
  })
end


return config
