# configs

个人配置仓库，包含可移植 dotfiles、NixOS、Home Manager 与 nix-darwin 配置。

## 使用方式

| 平台 | 方式 | Target |
| --- | --- | --- |
| 非 Nix 主机 | GNU Stow | `shell`、`editor`、`terminal` |
| NixOS | NixOS + Home Manager | `workstation`、`pve-guest` |
| macOS | nix-darwin + Homebrew | `macos` |

## Stow

在非 Nix 主机上，从仓库根目录链接需要的配置：

```bash
cd ~/configs
stow -Sv -t "$HOME" shell editor terminal
```

预览：

```bash
stow -Snv -t "$HOME" shell editor terminal
```

移除链接：

```bash
stow -Dv -t "$HOME" shell editor terminal
```

## macOS

安装 [Determinate Nix](https://docs.determinate.systems/) 和 Homebrew 后执行：

```bash
sudo -H nix run nix-darwin -- switch --flake ~/configs#macos
```

登录 App Store 后，运行 `mas-install-apps` 安装已声明的 App Store 应用。

## NixOS

部署桌面主机：

```bash
sudo nixos-rebuild switch --flake ~/configs#workstation
```

部署 PVE 虚拟机：

```bash
sudo nixos-rebuild switch --flake ~/configs#pve-guest
```

检查 Flake：

```bash
nix flake check
```

[GNU Stow]: https://www.gnu.org/software/stow/
