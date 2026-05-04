#!/bin/bash
set -euo pipefail

SETTING_KEY="SKIP_HOST_UPDATE"
EXPECTED_VALUE="true"

notify_restart() {
  if pgrep -x "discord" >/dev/null 2>&1; then
    echo ""
    echo "=== RESTART REQUEST ==="
    echo "Discord is currently running. Please restart Discord to apply the new settings."
    echo "========================"
  fi
}

detect_editor() {
  case "$(command -v jq; command -v python3; command -v perl)" in
    *jq*) echo "jq" ;;
    *python3*) echo "python3" ;;
    *perl*) echo "perl" ;;
    *) echo "error" ;;
  esac
}

process_home() {
  local home_dir="$1"
  local config_dir="$home_dir/.config/discord"
  local settings_file="$config_dir/settings.json"
  local backup_file="$settings_file.bak"

  [ -d "$home_dir" ] && [ -r "$home_dir" ] || return 0
  local owner
  owner=$(stat -c '%U:%G' "$home_dir")

  # FIRST CHECK: Is config already proper?
  if [ -f "$settings_file" ]; then
    if jq -e --arg key "$SETTING_KEY" --argjson val "$EXPECTED_VALUE" '.[$key] == $val' "$settings_file" >/dev/null 2>&1; then
      echo "$settings_file already correctly configured, skipping."
      return 0
    fi
    if ! jq . "$settings_file" >/dev/null 2>&1; then
      echo "WARNING: $settings_file is invalid JSON, will recreate" >&2
    fi
  fi

  # DETECT EDIT METHOD
  local editor
  editor=$(detect_editor)
  if [ "$editor" = "error" ]; then
    echo "ERROR: No JSON editor found (need jq/python3/perl)" >&2
    return 1
  fi

  if [ ! -d "$config_dir" ]; then
    mkdir -p "$config_dir"
    chmod 755 "$config_dir"
    chown "$owner" "$config_dir"
  fi

  if [ -f "$settings_file" ]; then
    cp "$settings_file" "$backup_file"
    echo "Created backup: $backup_file"
  fi

  local tmp_file="$settings_file.tmp"
  case "$editor" in
    jq)
      if [ -f "$settings_file" ] && [ -s "$settings_file" ]; then
        jq --arg key "$SETTING_KEY" --argjson val "$EXPECTED_VALUE" '.[$key] = $val' "$settings_file" | jq . > "$tmp_file"
      else
        jq -n --arg key "$SETTING_KEY" --argjson val "$EXPECTED_VALUE" '{($key): $val}' | jq . > "$tmp_file"
      fi
      ;;
    python3)
      if [ -f "$settings_file" ] && [ -s "$settings_file" ]; then
        python3 -c "import json; data=json.load(open('$settings_file')); data['$SETTING_KEY']=$EXPECTED_VALUE; json.dump(data, open('$tmp_file','w'), indent=2)"
      else
        python3 -c "import json; json.dump({'$SETTING_KEY': $EXPECTED_VALUE}, open('$tmp_file','w'), indent=2)"
      fi
      ;;
    perl)
      if [ -f "$settings_file" ] && [ -s "$settings_file" ]; then
        perl -MJSON::PP -e "my \$d=decode_json(do{local\$/=<>;<>});\$d->{'$SETTING_KEY'}=$EXPECTED_VALUE;print JSON::PP->new->pretty->encode(\$d)" < "$settings_file" > "$tmp_file"
      else
        perl -MJSON::PP -e "print JSON::PP->new->pretty->encode({'$SETTING_KEY'=>$EXPECTED_VALUE})" > "$tmp_file"
      fi
      ;;
  esac

  if ! jq . "$tmp_file" >/dev/null 2>&1; then
    echo "ERROR: Generated JSON invalid, cleaning up" >&2
    rm -f "$tmp_file"
    [ -f "$backup_file" ] && mv "$backup_file" "$settings_file"
    return 1
  fi

  mv "$tmp_file" "$settings_file"
  chmod 644 "$settings_file"
  chown "$owner" "$settings_file"
  echo "Updated $settings_file"
}

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed" >&2
  exit 1
fi

while IFS=: read -r user _ _ _ _ home _; do
  [[ "$home" == /home/* ]] || [[ "$home" == /root ]] && [ -d "$home" ] && process_home "$home" || true
done < /etc/passwd

notify_restart

echo "discord-fix hook completed"
