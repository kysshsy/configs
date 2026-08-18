{ config, pkgs, toshy, ... }:

let
  toshySource = pkgs.applyPatches {
    name = "toshy-patched";
    src = toshy;
    patches = [ (builtins.toFile "toshy-setuptools.patch" ''
      diff --git a/nix/toshy-runtime.nix b/nix/toshy-runtime.nix
      --- a/nix/toshy-runtime.nix
      +++ b/nix/toshy-runtime.nix
      @@ -62,7 +62,11 @@ let
               build-system = [
      -          (pyFinal.setuptools-scm.override { setuptools = pyFinal.setuptools_80; })
      +          (pyFinal.setuptools-scm.override { setuptools = pyFinal.setuptools; })
               ];
               dependencies = [ pyFinal.six ];
               doCheck = false;
               pythonImportsCheck = [ "Xlib" ];
             };
      +
      +      i3ipc = pyPrev.i3ipc.overridePythonAttrs (old: {
      +        dependencies = [ pyFinal.python-xlib ];
      +      });
    '') ];
  };
in

{
  services.toshy = {
    enable = true;
    runtimePackage = pkgs.callPackage "${toshySource}/nix/toshy-runtime.nix" {
      toshySrc = toshySource;
    };
  };

  xdg.configFile."toshy/toshy_config.py".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/nix/data/toshy/toshy_config.py";
}
