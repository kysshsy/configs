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
