#!/data/data/com.termux/files/usr/bin/bash
# HACK-LOCK :: updater
# Refreshes the installed skin from this repo folder.
# Your custom wallpaper and config are preserved.

set -u
INSTALL_DIR="$HOME/.hacklock"
SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_SUFFIX=".hacklock.bak"

[ -d "$INSTALL_DIR" ] || { echo "HACK-LOCK is not installed. Run: bash install.sh"; exit 1; }
[ -f "$SRC_DIR/hacklock" ] || { echo "Source repo not found next to update.sh."; exit 1; }

cp "$SRC_DIR/hacklock" "$INSTALL_DIR/hacklock"
cp "$SRC_DIR/uninstall.sh" "$INSTALL_DIR/uninstall.sh"
chmod +x "$INSTALL_DIR/hacklock" "$INSTALL_DIR/uninstall.sh"

# Never overwrite custom wallpaper / config.
[ -f "$INSTALL_DIR/config/config.sh" ] || cp "$SRC_DIR/config/config.sh" "$INSTALL_DIR/config/config.sh"
if [ ! -f "$INSTALL_DIR/wallpaper.jpg" ] && [ -f "$SRC_DIR/assets/hacklock-background.jpg" ]; then
  cp "$SRC_DIR/assets/hacklock-background.jpg" "$INSTALL_DIR/wallpaper.jpg"
fi

# Re-add the PATH command if it is missing.
if [ -n "${PREFIX:-}" ] && [ ! -e "$PREFIX/bin/hacklock" ]; then
  ln -sf "$INSTALL_DIR/hacklock" "$PREFIX/bin/hacklock" 2>/dev/null \
    || cp "$INSTALL_DIR/hacklock" "$PREFIX/bin/hacklock"
fi

# Re-add the auto-skin hook if it is missing.
if [ -f "$HOME/.bashrc" ] && ! grep -qF "# >>>>> HACK-LOCK" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF_HL'

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
  echo "[i] auto-skin hook re-added to ~/.bashrc"
fi

echo
echo "  HACK-LOCK updated. Run:  hacklock"