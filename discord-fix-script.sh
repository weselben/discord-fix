#!/bin/bash
set -euo pipefail

# === CONFIGURATION ===
SETTING_KEY="SKIP_HOST_UPDATE"
EXPECTED_VALUE="true"

# === FUNCTIONS ===

process_home() {
  local home_dir="$1"
  local config_dir="$home_dir/.config/discord"
  local settings_file="$config_dir/settings.json"
  local timestamp
  timestamp=$(date +%Y%m%dT%H%M%S)
  local backup_file="${settings_file}.discord-fix-backup-${timestamp}"

  # Skip invalid/unreadable homes
  if [[ ! -d "$home_dir" ]] || [[ ! -r "$home_dir" ]]; then
    return 0
  fi

  local owner
  owner=$(stat -c '%U:%G' "$home_dir" 2>/dev/null) || return 0

  # FIRST CHECK: Is config already proper?
  if [[ -f "$settings_file" ]] && jq -e --arg key "$SETTING_KEY" --argjson val "$EXPECTED_VALUE" '.[$key] == $val' "$settings_file" >/dev/null 2>&1; then
    echo "$settings_file already correctly configured, skipping."
    return 0
  fi

  # Create config dir if missing
  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
    chmod 755 "$config_dir"
    chown "$owner" "$config_dir"
  fi

  # Backup existing settings with timestamp
  if [[ -f "$settings_file" ]]; then
    cp "$settings_file" "$backup_file"
    echo "Created backup: $backup_file"
  fi

   # Apply change using jq (required dependency)
   local tmp_file="${settings_file}.tmp"
   
   # Update only our key, preserve everything else
   # Use jq to read and update in one pass
   if [[ -s "$settings_file" ]] && jq empty "$settings_file" 2>/dev/null; then
     jq --arg key "$SETTING_KEY" --argjson val "$EXPECTED_VALUE" '.[$key] = $val' "$settings_file" > "$tmp_file"
   else
     jq -n --arg key "$SETTING_KEY" --argjson val "$EXPECTED_VALUE" '{($key): $val}' > "$tmp_file"
   fi
   
   echo "Updated $settings_file (merged with existing config)"

  # Validate generated JSON
  if ! jq . "$tmp_file" >/dev/null 2>&1; then
    echo "ERROR: Generated JSON invalid, cleaning up" >&2
    rm -f "$tmp_file"
    [[ -f "$backup_file" ]] && mv "$backup_file" "$settings_file"
    return 1
  fi

  # Apply changes
  mv "$tmp_file" "$settings_file" || { rm -f "$tmp_file"; return 1; }
  chmod 644 "$settings_file"
  chown "$owner" "$settings_file"
  echo "Updated $settings_file"
}

notify_restart() {
  if pgrep -x "Discord" >/dev/null 2>&1; then
    echo ""
    echo "=== RESTART REQUEST ==="
    echo "Discord is currently running. Please restart Discord to apply the new settings."
    echo "========================"
  fi
}

# === MAIN ===

# Check for jq (required for validation)
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed" >&2
  exit 1
fi

# Process all user homes (or just current user if HOME is set to a test dir)
if [[ -n "${HOME_OVERRIDE:-}" ]]; then
  process_home "$HOME_OVERRIDE"
else
  while IFS=: read -r user _ _ _ _ home _; do
    if [[ "$home" == /home/* ]] || [[ "$home" == /root ]]; then
      [[ -d "$home" ]] && process_home "$home" || true
    fi
  done < /etc/passwd
fi

# Notify to restart Discord
notify_restart

echo "discord-fix: Completed successfully"
