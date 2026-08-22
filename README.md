# configs

个人配置仓库，包含可移植 dotfiles、NixOS、Home Manager 与 nix-darwin 配置。

## 目录结构

- `shell/`：Shell、Git、Starship、tmux 等可移植配置
- `editor/`：编辑器配置
- `terminal/`：终端配置
- `agentic/`：Codex 等 agent 配置
- `nix/`：NixOS、Home Manager、主机与硬件配置
  - `nix/hosts/`：可部署主机入口
  - `nix/hardware/`：硬件配置
  - `nix/modules/`：NixOS 和 Home Manager 模块

## Stow

非 Nix 主机使用 GNU Stow 安装可移植配置。仓库假设位于 `~/configs`：

```bash
cd ~/configs
stow -Sv -t "$HOME" shell editor terminal
```

预览将创建的链接：

```bash
stow -Snv -t "$HOME" shell editor terminal
```

卸载：

```bash
stow -Dv -t "$HOME" shell editor terminal
```

Stow 不会覆盖目标位置已有的普通文件；发生冲突时，请先备份或移除原文件。

在 NixOS 上，不要对 Home Manager 已管理的路径使用 Stow。

## macOS

`macos` target 使用 nix-darwin 管理系统，使用 nix-homebrew 安装及接管
Homebrew，并由 nix-darwin 声明安装与更新 Homebrew casks `codex`、
`visual-studio-code`、`google-chrome` 和 `mos`。目前目标为 Apple Silicon Mac，用户名为
`kyss`；部署前请按实际机器修改
`nix/hosts/macos/default.nix` 中的用户名和主机名。

先安装 [Determinate Nix](https://docs.determinate.systems/)，然后在仓库根目录
执行首次部署：

```bash
sudo -H nix run nix-darwin -- switch --flake ~/configs#macos
```

后续可运行 `darwin-rebuild switch --flake ~/configs#macos` 同步 Homebrew 和
Codex。Codex 只由 Home Manager 接管 `~/.codex/config.toml` 和
`~/.codex/AGENTS.md`；历史记录、认证信息、数据库、缓存和插件仍由 Codex
保存在用户目录中。该配置不会清理未在 Nix 中声明的其他 Homebrew 软件。

## NixOS

使用对应主机的 Flake target 部署：

```bash
sudo nixos-rebuild switch --flake ~/configs#workstation
```

仓库维护与配置归属规则见 [AGENTS.md](AGENTS.md)。

[GNU Stow]: https://www.gnu.org/software/stow/
