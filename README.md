# configs 使用说明

本仓库的配置文件使用 [GNU Stow] 统一管理。

- 每个子目录（如 `shell`、`editor`、`terminal`）表示一组相关配置。
- 在仓库根目录下，通过 stow 创建符号链接的方式把这些配置“安装”到 `$HOME`。

## 前置条件

- 已安装 `stow` 命令。
- 仓库路径假设为 `~/configs`，即本目录的父目录就是你的 `$HOME`。

## 安装（使用符号链接）

推荐使用 `-t` 显式指定目标目录，并一次性安装多个分组（group）：

在 `~/configs` 目录下，执行：

```bash
stow -Sv -t "$HOME" shell editor terminal
```

说明：

- `-t "$HOME"`：把链接安装到当前用户的 `$HOME` 目录（推荐显式写出）。
- `shell editor terminal`：作为多个“分组”（group）一起安装。
- `-S` 表示执行安装（stow）。
- `-v` 打印详细信息，方便确认创建了哪些符号链接。
- 可以加上 `-n`（如 `stow -Snv -t "$HOME" shell editor terminal`）先预览会创建/删除哪些链接。

## 卸载

同样使用 `-t`，可以一次性卸载多个分组：

```bash
stow -Dv -t "$HOME" shell editor terminal
```

- `-D` 表示卸载（delete），会删除 stow 创建的符号链接（不会删除仓库里的原始文件）。

## 链接冲突说明

如果 `$HOME` 中已经存在同名的普通文件或目录（不是由 stow 创建的符号链接），stow 不会覆盖这些目标，而是报告冲突并跳过对应条目。这种情况下需要先自行备份并移除原有文件，再重新执行安装。

[GNU Stow]: https://www.gnu.org/software/stow/

## NixOS

The root `flake.nix` defines declarative NixOS targets. It intentionally leaves
the existing Stow groups unchanged; Home Manager imports only portable Git,
editor, and terminal preferences.

The repository remains the single source of configuration files:

- On macOS and other conventional hosts, use Stow as documented above.
- On NixOS, the Flake reads selected files directly from this repository and
  installs their Nix-store links through Home Manager.
- Never run Stow for a path owned by Home Manager on NixOS. In the current
  setup those paths are Git, Neovim, Starship, WezTerm, Zellij, tmux, and
  Codex.
  Other groups can continue to use Stow once their paths do not overlap.

NixOS intentionally does not consume every dotfile in this repository. The
top-level Stow groups remain portable configuration for non-Nix systems and
may include package-manager helpers, local toolchains, proxies, and other
host-specific settings. A file not referenced by Nix is therefore not
automatically obsolete and must not be removed solely for that reason. See
`AGENTS.md` for the repository maintenance rules.

Hardware-dependent files live in `nix/hardware/`; do not use a configuration
from one machine on another machine. The available targets are:

| Target | Hardware profile | Use case |
| --- | --- | --- |
| `dev-bare-metal` | `nix/hardware/dev-bare-metal.nix` | Current Intel mini-PC, installed directly on Btrfs |
| `pve-niri-vm` | `nix/hardware/pve-niri-vm.nix` | Former PVE virtual machine using virtio disks |

For example, after changing `editor/.config/nvim/`, rebuild the current
bare-metal machine with:

```bash
sudo nixos-rebuild switch --flake ~/configs#dev-bare-metal
```

After the first successful rebuild, the system also provides shortcuts for the
current NixOS target:

```bash
nix-config-check
nix-config-rebuild
```

`nix-config-check` runs `nix flake check` without creating or updating a lock
file. `nix-config-rebuild` runs `sudo nixos-rebuild switch` for the target
installed on the current machine and will request the sudo password.

This makes configuration changes reviewable in Git and prevents files from
silently drifting away from the repository.

For the first deployment, clone this public repository over HTTPS on NixOS so
no GitHub private key is needed:

```bash
nix-shell -p git --run 'git clone https://github.com/kysshsy/configs.git ~/configs'
cd ~/configs
nix --extra-experimental-features 'nix-command flakes' flake lock
sudo nixos-rebuild switch --flake .#dev-bare-metal --option experimental-features 'nix-command flakes'
```

The rebuild turns off SSH password and keyboard-interactive authentication.
Keep the current SSH connection open and verify a second connection with your
Mac key before closing it:

```bash
ssh -o PasswordAuthentication=no kyss@192.168.0.106
```

After reconnecting, install the npm Codex CLI as `kyss` (not with `sudo`):

```bash
npm install -g @openai/codex
codex
```

Node.js and npm are supplied by Nix. The Flake directs npm's mutable global
packages to `~/.npm-packages`, while the executable is added to the shell PATH.

The Niri desktop starts on the bare-metal HDMI output after the rebuild. Log
in as `kyss`, then use `Super+T` for WezTerm, `Super+D` for the launcher, and
`Super+Shift+/` for the complete shortcut overlay. SSH remains available as
the recovery and administration path.
