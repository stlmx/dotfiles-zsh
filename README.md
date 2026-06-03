# dotfiles-zsh

一套可以在 macOS 和 Linux 服务器之间同步的 zsh 配置。主提示符使用 Starship，风格接近截图里的彩色 powerline：系统图标、用户名、目录、git 分支/状态、时间，以及下一行的绿色输入符。

## 功能

- Starship 彩色 powerline 主题，默认 prompt 前留空一行，视觉间距更宽
- SSH 登录 Linux 服务器时自动显示 `username@hostname`
- zsh-autosuggestions 和 zsh-syntax-highlighting
- Oh My Zsh 作为插件框架，Starship 负责 prompt
- conda、virtualenv、nvm 的基础兼容
- 每台机器的私有配置放在 `~/.zshrc.local`，不会进入仓库
- `install.sh` 安装/软链配置，`sync.sh` 用于服务器上快速同步

## 一键安装

```bash
git clone https://github.com/stlmx/dotfiles-zsh.git ~/dotfiles-zsh
cd ~/dotfiles-zsh
./install.sh
exec zsh
```

如果当前登录 shell 不是 zsh，按脚本最后提示执行：

```bash
chsh -s "$(command -v zsh)"
```

## 在服务器上同步更新

已经 clone 过之后，在任意服务器上执行：

```bash
cd ~/dotfiles-zsh
./sync.sh
exec zsh
```

等价于：

```bash
cd ~/dotfiles-zsh
git pull --ff-only
./install.sh
exec zsh
```

## 目录结构

- `zsh/.zshrc`：通用 zsh 初始化，不放任何密钥
- `zsh/.zshrc.local.example`：每台机器的私有配置模板
- `starship/starship.toml`：Starship prompt 主题
- `install.sh`：安装依赖并软链配置
- `sync.sh`：拉取最新仓库并重新安装软链

## 私有配置

把 API key、代理、CUDA 路径、服务器专属 alias 等内容放到：

```bash
~/.zshrc.local
```

示例：

```zsh
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
alias ll='ls -lah'
```

`install.sh` 第一次运行时会从 `zsh/.zshrc.local.example` 创建这个文件；后续不会覆盖。

## 依赖说明

脚本会尽量自动安装：

- Starship
- Oh My Zsh
- zsh-autosuggestions
- zsh-syntax-highlighting

如果服务器不能联网，或你只想建立软链，可以使用：

```bash
DOTFILES_SKIP_INSTALLS=1 ./install.sh
```

缺少 zsh 时先用系统包管理器安装：

```bash
sudo apt-get install zsh
```

或者：

```bash
sudo yum install zsh
```

## 字体

Starship 主题用了 Nerd Font 图标。通过 SSH 连接服务器时，字体由你本机终端决定；本机 Ghostty 里使用 Maple Mono NF CN 这类 Nerd Font 即可正常显示。

## 卸载

安装脚本会在覆盖前把旧文件备份到：

```bash
~/.dotfiles-zsh-backup-YYYYmmddHHMMSS
```

如果要恢复，删除软链并把备份文件拷回：

```bash
rm ~/.zshrc ~/.config/starship.toml
cp ~/.dotfiles-zsh-backup-*/.zshrc ~/.zshrc
cp ~/.dotfiles-zsh-backup-*/starship.toml ~/.config/starship.toml
```
