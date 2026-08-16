local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

config.color_scheme = 'Dracula+'

-- set font
config.font = wezterm.font('DejaVu Sans Mono',{})

config.keys = {
{
    key = 't',
    mods = 'CTRL',
    action = act.SpawnTab 'CurrentPaneDomain',
},
{
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentTab { confirm = false },
}
}
for i = 1, 8 do
  -- CTRL + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL',
    action = act.ActivateTab(i - 1),
  })
end


return config
