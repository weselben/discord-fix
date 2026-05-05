# discord-fix

A lightweight pacman hook package that automatically configures Discord to skip forced updates on Arch Linux and derivatives.

## 🎯 Problem

Discord on Linux periodically forces updates that can break the application or interrupt workflow. This package automatically sets `SKIP_HOST_UPDATE=true` in Discord's user settings to prevent this behavior.

## ✨ Features

- **Automatic Configuration**: Pacman hook triggers after Discord installation/upgrades
- **Non-Invasive**: Only modifies user-space config, never touches Discord binaries
- **Safe**: Creates timestamped backups before modifying settings
- **Idempotent**: Won't reconfigure already-correct settings
- **Multi-User Aware**: Configures settings for all user accounts
- **JSON Validation**: Uses `jq` for safe, validated JSON manipulation
- **Restart Notification**: Prompts users to restart Discord after configuration changes

## 📦 Installation

### From GitHub Releases (recommended for friends before AUR submission)

**One-liner (pipe latest release directly to pacman):**
```bash
curl -sL $(curl -s https://api.github.com/repos/weselben/discord-fix/releases/latest | jq -r '.assets[0].browser_download_url') | sudo pacman -U -
```

**Latest release direct link:**
```
https://github.com/weselben/discord-fix/releases/latest
```

**Or download + install:**
1. Download the latest release from [GitHub Releases](https://github.com/weselben/discord-fix/releases)
2. Install the package:
   ```bash
   sudo pacman -U discord-fix-*.pkg.tar.zst
   ```
3. Or using Octopi: Use "Install local package" and select the downloaded file.

### Using AUR helpers (once published to AUR)

```bash
# Using yay
yay -S discord-fix

# Using paru
paru -S discord-fix

# Using Octopi
# Search for "discord-fix" in the AUR section
```

### Build from source

```bash
git clone https://github.com/weselben/discord-fix.git
cd discord-fix
makepkg -si
```

## 🔧 How It Works

1. **Pacman Hook** (`/usr/share/libalpm/hooks/discord-fix.hook`):
   - Triggers on Discord package install/upgrade
   - Runs the fix script as post-transaction action

2. **Fix Script** (`/usr/lib/discord-fix/discord-fix-script.sh`):
   - Checks `~/.config/discord/settings.json` for each user
   - If `SKIP_HOST_UPDATE` is not `true`, updates it
   - Creates timestamped backups before any modification
   - Validates JSON to prevent corruption

3. **Install Script** (`discord-fix.install`):
   - Runs the fix on initial package installation
   - Ensures immediate configuration after install

## 📋 Configuration

The package automatically sets:
```json
{
  "SKIP_HOST_UPDATE": true
}
```

No additional configuration is required. The setting is applied automatically.

## 🔍 Verification

After installation, verify the setting was applied:

```bash
cat ~/.config/discord/settings.json | jq .SKIP_HOST_UPDATE
# Should output: true
```

## 🚨 Troubleshooting

### Discord still updates

1. Ensure the package is installed: `pacman -Q discord-fix`
2. Check if Discord is running: `pgrep -x Discord`
3. Restart Discord after package installation
4. Verify the setting: `jq .SKIP_HOST_UPDATE ~/.config/discord/settings.json`

### Settings not applied

Check the pacman hook log:
```bash
sudo journalctl -u pacman 2>&1 | grep discord-fix
```

Manually run the script:
```bash
sudo /usr/lib/discord-fix/discord-fix-script.sh
```

### Backup files

Timestamped backups are created at:
```
~/.config/discord/settings.json.discord-fix-backup-YYYYMMDDTHHMMSS
```

Restore from backup if needed:
```bash
cp ~/.config/discord/settings.json.discord-fix-backup-YYYYMMDDTHHMMSS ~/.config/discord/settings.json
```

## 📊 Dependencies

- `discord` - The Discord application
- `bash` - Script runtime
- `jq` - JSON processing and validation
- `procps-ng` - Process detection for restart notifications

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using [Conventional Commits](https://www.conventionalcommits.org/)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
git clone https://github.com/weselben/discord-fix.git
cd discord-fix
makepkg -s  # Install dependencies and build
```

### Pre-Commit Hooks

The repository includes pre-commit hooks that verify:
- PKGBUILD checksum validity
- .SRCINFO matches PKGBUILD
- Arch packaging guidelines compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚖️ Disclaimer

This package modifies Discord's user settings only. It does not modify, reverse engineer, or redistribute Discord itself. Discord is a trademark of Discord Inc. This package is not affiliated with or endorsed by Discord Inc.

## 🔗 Links

- [GitHub Repository](https://github.com/weselben/discord-fix)
- [Issue Tracker](https://github.com/weselben/discord-fix/issues)

> **Note**: AUR package link will be added once the package is submitted to AUR.

## 🎖️ Acknowledgments

- Arch Linux community for packaging guidelines
- Discord team for the application (despite the forced updates 😉)
