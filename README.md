# Zsh Configuration

A personal, lightweight Zsh configuration focused on a fast and practical terminal workflow on Fedora.

This configuration does **not** use Oh My Zsh. It relies on Zsh itself plus a small set of independent tools and plugins.

## Features

- Fast and cached Zsh completion
- Two-line Git-aware prompt
- Python virtual-environment helpers
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `zsh-history-substring-search`
- `fzf` integration
- `fzf-tab` completion
- `zoxide` directory jumping
- `forgit` Git fuzzy interface
- `eza` with Nerd Font icons
- Useful Git shortcuts
- Safe `cp`, `mv`, and `rm` aliases
- Wayland/X11 clipboard helpers
- Archive extraction helper
- Optional lazy-loaded NVM support
- Optional `pyenv` and `direnv` integration
- Fedora `command-not-found` integration
- Local configuration support through `~/.config/zsh/conf.d/`

## Prompt

The prompt is intentionally minimal and information-focused. It shows:

- username and hostname
- current directory
- active Python virtual environment
- Git branch
- the exit status of the previous command when it fails

The home directory is displayed as `home` instead of `~`, and the prompt keeps the last two path components visible.

Example:

```text
╭─ amirali@fedora in home/Orbitlang
╰─❯
```

## Requirements

### Required

- Zsh
- Git
- fzf

### Recommended

- eza
- fd
- bat
- zoxide
- a Nerd Font

### Plugins

The configuration supports these plugins:

- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-history-substring-search
- fzf-tab
- forgit

No plugin manager is required.

## Fedora setup

Install the main packages:

```bash
sudo dnf install zsh fzf eza fd-find bat zoxide git
```

Package availability can vary between Fedora releases. Install only the packages available on your system.

For `zsh-autosuggestions` and `zsh-syntax-highlighting`, Fedora packages can be used when available.

## Plugin setup

The configuration expects manually installed plugins under:

```text
~/.config/zsh/plugins/
```

Example:

```bash
mkdir -p ~/.config/zsh/plugins

cd ~/.config/zsh/plugins
git clone https://github.com/Aloxaf/fzf-tab.git fzf-tab
git clone https://github.com/wfxr/forgit.git forgit
git clone https://github.com/zsh-users/zsh-history-substring-search.git zsh-history-substring-search
```

The Fedora packages for autosuggestions and syntax highlighting are loaded from `/usr/share/zsh/` when present.

## Installation

Back up your existing configuration first:

```bash
cp ~/.zshrc ~/.zshrc.backup
```

Then copy this configuration to `~/.zshrc`:

```bash
cp .zshrc ~/.zshrc
```

Validate the file before starting a new shell:

```bash
zsh -n ~/.zshrc
```

If there is no output, start a new Zsh session:

```bash
exec zsh
```

## Useful shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl + R` | Fuzzy history search |
| `Ctrl + T` | Fuzzy file search |
| `Alt + C` | Fuzzy directory search |
| `Tab` | Interactive `fzf-tab` completion |
| `↑` / `↓` | History substring search |
| `Ctrl + \` | Accept autosuggestion |
| `Ctrl + ←` / `Ctrl + →` | Move by word |
| `Ctrl + Backspace` | Delete previous word |
| `Ctrl + X`, `Ctrl + E` | Edit the current command in `$EDITOR` |
| `Esc`, `Esc` | Toggle `sudo` on the current command |

## Useful commands

### Python

```bash
py
venv .venv
activate
mkvenv
```

`activate` automatically looks for either `.venv` or `venv` in the current directory.

### Git

```bash
gs        # git status
ga        # git add
gc        # git commit
gp        # git push
gpl       # git pull
gsw       # git switch
gswc      # git switch -c
gd        # git diff
gdc       # git diff --cached
gl        # compact graph log
```

### Navigation

```bash
..
...
....
-
up 3
mkcd project
```

### Files and archives

```bash
backup file.txt
extract archive.tar.gz
```

### Clipboard

```bash
echo "hello" | copy
paste
```

The clipboard helper automatically uses `wl-copy`/`wl-paste`, `xclip`, or `xsel` depending on what is installed.

## Local configuration

Machine-specific settings can be placed in:

```text
~/.config/zsh/conf.d/*.zsh
```

These files are loaded automatically without modifying the main `.zshrc`.

## Philosophy

The goal is not to turn Zsh into a huge framework. The configuration keeps the shell close to native Zsh while adding tools that provide a clear practical benefit.

No Oh My Zsh. No large framework. No unnecessary plugin manager.

## License

Feel free to use, modify, and adapt this configuration for your own setup.
