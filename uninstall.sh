#!/data/data/com.termux/files/usr/bin/bash
# HACK-LOCK :: uninstaller
# Removes ONLY what HACK-LOCK added. Your Termux, packages and files stay.

set -u
INSTALL_DIR="$HOME/.hacklock"
BACKUP_SUFFIX=".hacklock.bak"

confirm() {
  printf "Remove HACK-LOCK? (~/.hacklock will be deleted) [y/N] "
  read -r ans
  case "$ans" in y|Y|yes|YES) return 0 ;; *) echo "Aborted."; exit 1 ;; esac
}
confirm

strip_hook() {
  local file="$1"
  [ -f "$file" ] || return
  if grep -qF "# >>>>> HACK-LOCK" "$file" 2>/dev/null; then
    awk '
      /^# >>>>> HACK-LOCK/ { skip=1 }
      !skip                { print }
      /^# <<<<< HACK-LOCK/ { skip=0 }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "[i] auto-skin hook removed from $file"
  fi
}

# Remove the hook from ~/.bashrc (backup keeps your history intact anyway).
strip_hook "$HOME/.bashrc"

# Restore login-profile files we touched, or remove a profile we created.
restore_profile() {
  local p="$1"
  [ -f "$p" ] || return
  if [ -f "$p$BACKUP_SUFFIX" ]; then
    cp "$p$BACKUP_SUFFIX" "$p"
    rm -f "$p$BACKUP_SUFFIX"
    echo "[i] restored $p from backup."
    return
  fi
  # Remove the "load ~/.bashrc" line we added; drop the file if it only
  # contained that single line (i.e. we created it from scratch).
  grep -vF '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"' "$p" > "$p.tmp"
  if [ -s "$p.tmp" ]; then
    mv "$p.tmp" "$p"
  else
    rm -f "$p.tmp" "$p"
    echo "[i] removed $p (created by HACK-LOCK)."
  fi
}
restore_profile "$HOME/.bash_profile"
restore_profile "$HOME/.profile"

if [ -n "${PREFIX:-}" ]; then
  rm -f "$PREFIX/bin/hacklock"
  echo "[i] removed $PREFIX/bin/hacklock"
fi

rm -rf "$INSTALL_DIR"
echo "[i] removed $INSTALL_DIR"

echo
echo "  HACK-LOCK removed. Your Termux is unchanged."
echo "  Open a NEW Termux session to see the normal look again."