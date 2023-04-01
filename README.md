# Zsh-File-Manager

```
Zsh-File-Manager Manual

Base on "zsh" using "fzf", the File-Manager is a lightweight tool
that incorporates "exa" and "bat" for enhanced functionality.

Binding keys:

C-u                 preview window page up
C-d                 preview window page down
C-s                 preview window horizontally
C-v                 preview window vertically
C-k, C-p, up        up
C-j, C-n, down      down
C-h, left           back "cd .."
C-l, right enter    selected
                      if it is a directory, it enters it.
                      if it is a file, it adds the filename to the terminal BUFFER.
pgup                page up
pgdn                page down
C-c, C-f, C-g       quit

About fallback:

If "exa" is not installed, it will use "ls" as a fallback.
If "bat" is not installed, it will use "cat" as a fallback.
```

![selected directory](https://raw.githubusercontent.com/JoverZhang/zsh-file-manager/resources/zsh-file-manager-1.png)

![selected file](https://raw.githubusercontent.com/JoverZhang/zsh-file-manager/resources/zsh-file-manager-2.png)

# Usage

## Manual (Git Clone)

1. Clone this repository somewhere on your machine. This guide will assume `~/.zsh/zsh-file-manager`.

```sh
git clone https://github.com/JoverZhang/zsh-file-manager ~/.zsh/zsh-file-manager
```

2. Add the following to your `.zshrc`:

```sh
source ~/.zsh/zsh-file-manager/zsh-file-manager.zsh
```

3. Start a new terminal session.
