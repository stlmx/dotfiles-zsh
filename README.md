# dotfiles-zsh

一套可以在 macOS 和 Linux 服务器之间同步的 zsh 和 tmux 配置。主提示符使用 Starship，简约两行：系统图标、用户名@主机名、目录、git 分支/状态，右侧是耗时和时间，下一行是绿色输入符。tmux 底栏是暮紫色，见下文「tmux」。

## 功能

- Starship 简约两行主题：不用底色，只靠文字颜色区分各段；只有开头的系统图标用 Nerd Font；上一条命令超过 2 秒才显示耗时，失败时输入符变红；默认 prompt 前留空一行
- 用户名始终显示（root 标红）；主机名不自动显示，需要时可在每台机器上用 `DOTFILES_PROMPT_HOST` 自定义短名字
- zsh-autosuggestions 和 zsh-syntax-highlighting
- Oh My Zsh 作为插件框架，Starship 负责 prompt
- conda、virtualenv、nvm 的基础兼容
- 每台机器的私有配置放在 `~/.zshrc.local`，不会进入仓库
- tmux：暮紫底栏，Claude Code 会话状态标记；每台机器的私有设置放在 `~/.tmux.conf.local`
- 命令行工具：eza 代替 `ls`、bat 代替 `cat`、fzf 模糊搜索、zoxide 目录跳转、Yazi 文件管理器、abtop 看 AI 会话，见下文「命令行工具」
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

## Git 状态快照

提示符不再每次回车都扫描工作区，分支名实时显示，状态（`!` 修改、`?` 未跟踪、`+` 暂存、`⇡⇣` 领先/落后、`$` stash、绿色 `✓` 干净且与上游一致）是快照：

- 进入一个新仓库时自动算一次；
- 手动刷新：`mgit`（即 `git-refresh`）、`Ctrl+X Ctrl+G`，或在终端里连按两次 `Cmd+M`；
- 不联网，`⇡⇣` 与 `✓` 以最近一次 `git fetch` 为准。

`Cmd+M` 需要本地终端把它映射成 `ESC[9001~`：

- Otty：`~/.config/otty/config.toml` 加 `keybind = "cmd+m=csi:9001~"`；
- VS Code（含 Remote-SSH）：`keybindings.json` 加 `{"key": "cmd+m cmd+m", "command": "workbench.action.terminal.sendSequence", "args": {"text": "\u001b[9001~\u001b[9001~"}, "when": "terminalFocus"}`。

需要 git ≥ 2.11（低版本只是不显示状态，不报错）。字体要求见下文「字体」。

## tmux

`install.sh` 把 `tmux/tmux.conf` 软链到 `~/.tmux.conf`。需要 tmux ≥ 3.2 和支持真彩色的终端（Ghostty、iTerm2 等）；已经开着的 tmux 运行 `tmux source-file ~/.tmux.conf` 生效。

- 前缀键是反引号 `` ` ``，要打出反引号本身就连按两次；开了鼠标；
- 底栏是暮紫色：偏暗偏灰的紫色底，只比深色终端亮一点；米白字，会话名浅粉；你所在的窗口挖成终端底色，像浏览器的当前标签；其他窗口灰字，响过铃还没去看的变米白；
- Claude Code 会话状态：窗口名前绿 `✓` = 答完在等你，黄 `?` = 等你授权，红 `!` = 撞了额度或接口出错。由 Claude Code 的钩子写窗口选项 `@claude`，没装钩子的机器上不显示；
- 右边是当前窗格的标题和时钟。时钟默认是本机时区；服务器跑在 UTC 又想看别的时区，在 `~/.tmux.conf.local` 里改 `@clock`，例子见 `tmux/tmux.conf.local.example`。

每台机器的私有设置（时区、本机才有的脚本快捷键等）放 `~/.tmux.conf.local`，`~/.tmux.conf` 最后加载它；`install.sh` 第一次运行时从示例创建，之后不覆盖。

## 命令行工具

`.zshrc` 里每个工具都先检查装没装，没装的机器上保持原生命令，不报错。`install.sh` 只软链它们的设置，不负责安装工具本身。

Mac 上安装：

```bash
brew install eza bat fzf zoxide yazi sevenzip fd ripgrep resvg
```

Yazi 的视频、PDF、图片预览还用到 ffmpeg、poppler、imagemagick，普通版就够，不需要 `-full` 版。abtop 不在 Homebrew 里，从 [GitHub Releases](https://github.com/graykode/abtop/releases) 下载对应平台的压缩包，核对 `.sha256` 后把 `abtop` 放进 `~/.local/bin`。

- eza：`ls` 目录在前、带图标；`ll` 详细列表，带表头和 Git 状态列；`lt` 两层树状图，跳过 `.gitignore` 里的文件。按时间排序用 `ll -s modified`，eza 的 `-t` 和 GNU `ls` 不一样
- bat：`cat` 带语法高亮、行号和 Git 改动标记，配色 `ansi` 跟着终端皮肤走；接管道或重定向时自动退回纯文本；要复制纯文本用 `cat -p`。Ubuntu 上 apt 装的命令叫 `batcat`，会自动对上
- fzf：`Ctrl+R` 模糊搜历史命令，`Ctrl+T` 模糊找文件，右边预览文件内容或目录树。需要 fzf ≥ 0.48，老版本自动跳过
- zoxide：`z 关键词` 跳到常去的目录，`zi` 从列表里挑；`cd` 保持原样
- extract：Oh My Zsh 插件，`x 文件名` 解压各种压缩包
- Yazi：`y` 启动，`q` 退出时终端跟着进到最后停留的目录，`Q` 退出不跳。`d` 删到废纸篓，`D` 永久删除。设置在 `yazi/yazi.toml`：Mac 上文本文件按回车用 VS Code 打开，其他系统用 `$EDITOR`
- abtop：`abtop` 打开 AI 编程会话面板（Claude Code、Codex）。设置在 `abtop/config.toml`，界面中文；在 abtop 里换配色或开关面板会写回这个文件。它会在后台调用 `claude --print` 给会话起标题，不经过 `.zshrc.local` 里的代理函数

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
- `zsh/git-status-cache.zsh`：git 状态快照与刷新快捷键（由 `.zshrc` 加载）
- `starship/starship.toml`：Starship prompt 主题
- `tmux/tmux.conf`：tmux 配置（暮紫底栏）
- `tmux/tmux.conf.local.example`：每台机器的 tmux 私有设置模板
- `yazi/yazi.toml`：Yazi 设置（打开文本文件用什么）
- `abtop/config.toml`：abtop 设置（中文界面）
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

如果服务器自动 hostname 太长，可以自己定义 prompt 里的短名字：

```zsh
export DOTFILES_PROMPT_HOST=h100
```

不设置 `DOTFILES_PROMPT_HOST` 时，prompt 只显示用户名，不显示主机名。

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

Starship 主题开头的系统图标用了 Nerd Font。通过 SSH 连接服务器时，字体由你本机终端决定；本机 Ghostty / Otty / VS Code 终端里使用 Maple Mono NF CN 这类 Nerd Font 即可正常显示。

## 卸载

安装脚本会在覆盖前把旧文件备份到：

```bash
~/.dotfiles-zsh-backup-YYYYmmddHHMMSS
```

如果要恢复，删除软链并把备份文件拷回：

```bash
rm ~/.zshrc ~/.config/starship.toml ~/.tmux.conf ~/.config/yazi/yazi.toml ~/.config/abtop/config.toml
cp ~/.dotfiles-zsh-backup-*/.zshrc ~/.zshrc
cp ~/.dotfiles-zsh-backup-*/starship.toml ~/.config/starship.toml
cp ~/.dotfiles-zsh-backup-*/.tmux.conf ~/.tmux.conf    # 原来有才有
```
