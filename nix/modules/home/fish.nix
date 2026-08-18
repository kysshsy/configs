{ ... }:

{
  # Link Fish item by item so fish_variables remains writable runtime state.
  xdg.configFile = {
    "fish/config.fish".source = ../../../shell/.config/fish/config.fish;
    "fish/completions".source = ../../../shell/.config/fish/completions;
    "fish/conf.d".source = ../../../shell/.config/fish/conf.d;
    "fish/functions".source = ../../../shell/.config/fish/functions;
    "fish/manual".source = ../../../shell/.config/fish/manual;
  };
}
