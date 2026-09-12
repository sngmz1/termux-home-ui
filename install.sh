#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  HACK-LOCK :: Termux skin installer
#  Installs a simple visual skin (image header + green theme)
#  on TOP of the real Termux. Termux is never replaced.
#
#  usage (inside Termux):
#    cd hacklock
#    bash install.sh
# ============================================================
set -u

INSTALL_DIR="$HOME/.hacklock"
SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_SUFFIX=".hacklock.bak"

say()  { printf "\033[92;1m[+] %s\033[0m\n" "$*"; }
warn() { printf "\033[93;1m[!] %s\033[0m\n" "$*"; }
err()  { printf "\033[91;1m[x] %s\033[0m\n" "$*"; exit 1; }

echo
say "HACK-LOCK :: Termux skin installer"

# 1) Must run inside Termux (Android).
if [ -z "${PREFIX:-}" ] && ! command -v pkg >/dev/null 2>&1; then
  err "Run this inside Termux on Android:  bash install.sh"
fi

# 2) Required package: chafa (renders the wallpaper in the terminal).
if ! command -v chafa >/dev/null 2>&1; then
  say "Installing chafa (renders the wallpaper as the terminal header)..."
  if command -v pkg >/dev/null 2>&1; then
    pkg install -y chafa || {
      warn "chafa install failed - run manually:  pkg update && pkg install chafa"
      warn "Continuing without the image header (text banner will be used)."
    }
  else
    warn "No 'pkg' command found - chafa will not be installed."
  fi
else
  say "chafa already installed."
fi

# 3) Install files to ~/.hacklock.
say "Installing files to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR/config" || err "Cannot create $INSTALL_DIR"

cp "$SRC_DIR/hacklock"     "$INSTALL_DIR/hacklock"     || err "copy hacklock failed"
cp "$SRC_DIR/uninstall.sh" "$INSTALL_DIR/uninstall.sh" || err "copy uninstall.sh failed"
[ -f "$INSTALL_DIR/config/config.sh" ] || \
  cp "$SRC_DIR/config/config.sh" "$INSTALL_DIR/config/config.sh"
if [ ! -f "$INSTALL_DIR/wallpaper.jpg" ] && [ -f "$SRC_DIR/assets/hacklock-background.jpg" ]; then
  cp "$SRC_DIR/assets/hacklock-background.jpg" "$INSTALL_DIR/wallpaper.jpg"
fi
chmod +x "$INSTALL_DIR/hacklock" "$INSTALL_DIR/uninstall.sh"

# 4) Put 'hacklock' on the PATH.
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
  if ln -sf "$INSTALL_DIR/hacklock" "$PREFIX/bin/hacklock" 2>/dev/null; then
    say "Command installed: $PREFIX/bin/hacklock"
  else
    cp "$INSTALL_DIR/hacklock" "$PREFIX/bin/hacklock"
    chmod +x "$PREFIX/bin/hacklock"
    say "Command installed (copy): $PREFIX/bin/hacklock"
  fi
else
  warn "Could not install 'hacklock' on PATH - use:  bash ~/.hacklock/hacklock"
fi

# 5) Skin every new Termux session automatically.
add_hook() {
  local file="$1"
  if [ -f "$file" ] && grep -qF "# >>>>> HACK-LOCK" "$file" 2>/dev/null; then
    return
  fi
  if [ -f "$file" ]; then
    cp "$file" "$file$BACKUP_SUFFIX" && say "Backup: $file$BACKUP_SUFFIX"
  fi
  cat >> "$file" <<'EOF_HL'

# >>>>> HACK-LOCK >>>>>
# Visual skin for Termux. Removed by uninstall.sh.
[ -f "$HOME/.hacklock/config/config.sh" ] && . "$HOME/.hacklock/config/config.sh"
export LS_COLORS="di=01;32:ln=01;36:ex=01;33:*.sh=01;32:*.py=01;32:"
PS1="\[\e[32m\][${HACKLOCK_USER_TEXT:-HACK-LOCK} \w]\$ \[\e[0m\]"
__hacklock_resize() {
  local c
  c=$(tput cols 2>/dev/null || printf '0')
  if [ "$c" != "${HACKLOCK_LAST_COLS:-}" ]; then
    HACKLOCK_LAST_COLS="$c"
    if [ -t 1 ] && [ -f "$HOME/.hacklock/hacklock" ]; then
      bash "$HOME/.hacklock/hacklock"
    fi
  fi
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__hacklock_resize"
# <<<<< HACK-LOCK <<<<<
EOF_HL
  say "Auto-skin added to $file"
}

[ -f "$HOME/.bashrc" ] || { touch "$HOME/.bashrc"; say "Created ~/.bashrc"; }
add_hook "$HOME/.bashrc"

# Termux login shells may read ~/.bash_profile / ~/.profile instead of
# ~/.bashrc. Make sure one of them loads ~/.bashrc (backing up originals).
ensure_bashrc_sourced() {
  local profile="$HOME/.bash_profile"
  if [ ! -f "$profile" ]; then
    if [ -f "$HOME/.profile" ]; then
      profile="$HOME/.profile"
    else
      profile="$HOME/.bash_profile"
      printf '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"\n' > "$profile"
      say "Created $profile (loads ~/.bashrc)."
      return
    fi
  fi
  if grep -qF '~/.bashrc' "$profile" || grep -qF '$HOME/.bashrc' "$profile"; then
    say "$profile already loads ~/.bashrc."
  else
    [ -f "$profile$BACKUP_SUFFIX" ] || cp "$profile" "$profile$BACKUP_SUFFIX"
    printf '\n[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"\n' >> "$profile"
    say "Made $profile load ~/.bashrc (backup: $profile$BACKUP_SUFFIX)."
  fi
}
ensure_bashrc_sourced

# 6) Done.
echo
say "DONE."
echo
echo "  Apply HACK-LOCK now:                hacklock"
echo "  Or just open a NEW Termux session (it skins itself automatically)."
echo
echo "  Customize:                          hacklock --config"
echo "  Replace wallpaper:                  ~/.hacklock/wallpaper.jpg"
echo "  Remove:                             bash ~/.hacklock/uninstall.sh"
echo