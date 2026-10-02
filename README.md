[README.md](https://github.com/user-attachments/files/32980416/README.md)
# unix_dotfiles

Personal dotfiles for CachyOS/Arch and macOS: zsh, Ghostty, fastfetch, and Neovim (LazyVim).

| OS | Playbook | Package manager |
| --- | --- | --- |
| CachyOS / Arch | `playbook.yml` | pacman |
| macOS (Apple Silicon or Intel) | `playbook-macos.yml` | Homebrew |

Both playbooks copy the same dotfiles and use the same tags.

## Automatic setup (Ansible)

### CachyOS / Arch

```
sudo pacman -S ansible git
git clone https://github.com/MalariaKills/unix_dotfiles ~/.dotfiles
cd ~/.dotfiles
ansible-playbook playbook.yml -K
```

### macOS

Install [Homebrew](https://brew.sh) first (it also installs the Xcode Command Line Tools, which provide `git`), then:

```
brew install ansible
ansible-galaxy collection install community.general
git clone https://github.com/MalariaKills/unix_dotfiles ~/.dotfiles
cd ~/.dotfiles
ansible-playbook playbook-macos.yml -K
```

The playbook stops with a clear message if Homebrew isn't installed.

### Both

`-K` prompts for your sudo password (needed to install packages and change your login shell).

This runs everything in the Manual section below in one go. Useful tags if you don't want everything:

- `--tags config` — only copy the dotfiles and sync LazyVim, skip installing packages or changing your shell
- `--tags packages` — only install the packages
- `--skip-tags system` — skip package install and shell change, just refresh configs

### macOS server mode

`playbook-macos.yml` has an extra `server` tag for an always-on, headless Mac (e.g. a Mac mini running self-hosted apps). It never runs unless you ask for it:

```
ansible-playbook playbook-macos.yml -K --tags all,server   # everything, plus server setup
ansible-playbook playbook-macos.yml -K --tags server       # server setup only
```

It:

- Installs [OrbStack](https://orbstack.dev) (lighter replacement for Docker Desktop) and tmux
- Clones [Odysseus](https://github.com/pewdiepie-archdaemon/odysseus) to `~/self-hosted/odysseus` (first run only) and runs it in the background with a launchd agent, so it starts at login and restarts if it crashes. Run just this part with `--tags odysseus`. Your Odysseus `.env` isn't managed by the playbook.
- Disables sleep, restarts after a power failure or a system freeze, and enables wake on network access
- Turns off sending crash and usage analytics to Apple
- Stops apps from reopening after a reboot

Odysseus everyday commands:

```
launchctl kickstart -k gui/$(id -u)/local.odysseus   # restart (e.g. after git pull)
launchctl bootout gui/$(id -u)/local.odysseus        # stop
tail -f ~/Library/Logs/odysseus.log                  # logs
```

It deliberately does **not** touch iCloud, FileVault, auto-login, or uninstall Docker Desktop. Make those calls by hand, and migrate your containers to OrbStack before removing Docker Desktop.

## Manual setup

### 1. Install packages

**CachyOS / Arch:**

```
sudo pacman -S zsh ghostty fastfetch neovim git base-devel eza bat fzf zoxide ripgrep fd unzip ttf-jetbrains-mono-nerd
```

**macOS** (zsh, git, and build tools come with macOS and the Xcode Command Line Tools):

```
brew install fastfetch neovim eza bat fzf zoxide ripgrep fd
brew install --cask ghostty font-jetbrains-mono-nerd-font
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

On macOS, switch fastfetch to the Mac logo:

```
sed -i '' 's/"CachyOS_small"/"macos_small"/' ~/.config/fastfetch/config.jsonc
```

### 4. Install LazyVim's plugins

```
nvim --headless "+Lazy! sync" +qa
```

### 5. Make zsh your login shell

**CachyOS / Arch:**

```
chsh -s /usr/bin/zsh
```

**macOS:** zsh is already the default login shell. If you changed it, run `chsh -s /bin/zsh`.

Log out and back in (or just open a new Ghostty window).

## First launch (either method)

- The first time zsh starts, it clones `zinit` and installs Powerlevel10k and the other shell plugins automatically. This takes a few seconds and only happens once.
- In your terminal's font settings, pick a Nerd Font (e.g. "JetBrainsMono Nerd Font") so icons in the prompt and fastfetch render correctly.
- If the prompt looks wrong after that, run `p10k configure` to rebuild it.

## Notes

- The fastfetch config uses the small CachyOS logo (`CachyOS_small`). The macOS playbook swaps it to `macos_small` automatically; on another distro, edit the `"source"` field in `fastfetch/config.jsonc`.
- `.zshrc` loads Homebrew from `/opt/homebrew` when it exists, so the same file works on both systems.
- Ghostty can't remember window size across restarts on Linux, so `ghostty/config` sets a fixed 120x35 default instead. macOS gets the same default.
- The Arch playbook was tested against an isolated fake `$HOME` before being committed, so it's safe to run on a fresh machine. The macOS playbook passes Ansible's syntax check; do a first run with `--check` to preview its changes.
