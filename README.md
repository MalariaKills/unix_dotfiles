# unix_dotfiles

Personal dotfiles for CachyOS/Arch: zsh, Ghostty, fastfetch, and Neovim (LazyVim).

## Automatic setup (Ansible)

```
sudo pacman -S ansible git
git clone https://github.com/MalariaKills/unix_dotfiles ~/.dotfiles
cd ~/.dotfiles
ansible-playbook playbook.yml -K
```

`-K` prompts for your sudo password (needed to install packages and change your login shell).

This runs everything in the Manual section below in one go. Useful tags if you don't want everything:

- `--tags config` — only copy the dotfiles and sync LazyVim, skip installing packages or changing your shell
- `--tags packages` — only install the packages
- `--skip-tags system` — skip package install and shell change, just refresh configs

## Manual setup

### 1. Install packages

```
sudo pacman -S zsh ghostty fastfetch neovim git base-devel eza bat fzf zoxide ripgrep fd unzip ttf-jetbrains-mono-nerd
```

### 2. Clone this repo

```
git clone https://github.com/MalariaKills/unix_dotfiles ~/.dotfiles
```

### 3. Copy the configs into place

```
mkdir -p ~/.config/ghostty ~/.config/fastfetch ~/.config/nvim
cp ~/.dotfiles/zsh/.zshrc ~/.zshrc
cp ~/.dotfiles/ghostty/config ~/.config/ghostty/config
cp ~/.dotfiles/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
cp -r ~/.dotfiles/nvim/. ~/.config/nvim/
```

### 4. Install LazyVim's plugins

```
nvim --headless "+Lazy! sync" +qa
```

### 5. Make zsh your login shell

```
chsh -s /usr/bin/zsh
```

Log out and back in (or just open a new Ghostty window).

## First launch (either method)

- The first time zsh starts, it clones `zinit` and installs Powerlevel10k and the other shell plugins automatically. This takes a few seconds and only happens once.
- In your terminal's font settings, pick a Nerd Font (e.g. "JetBrainsMono Nerd Font") so icons in the prompt and fastfetch render correctly.
- If the prompt looks wrong after that, run `p10k configure` to rebuild it.

## Notes

- The fastfetch config uses the small CachyOS logo (`CachyOS_small`). On a different distro, edit the `"source"` field in `fastfetch/config.jsonc`.
- Ghostty can't remember window size across restarts on Linux, so `ghostty/config` sets a fixed 120x35 default instead.
- The Ansible playbook was tested against an isolated fake `$HOME` before being committed, so it's safe to run on a fresh machine.
