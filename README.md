# configs

个人配置仓库，包含可移植 dotfiles 与 NixOS/Home Manager 配置。

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

## NixOS

使用对应主机的 Flake target 部署：

```bash
sudo nixos-rebuild switch --flake ~/configs#workstation
```

仓库维护与配置归属规则见 [AGENTS.md](AGENTS.md)。

[GNU Stow]: https://www.gnu.org/software/stow/
