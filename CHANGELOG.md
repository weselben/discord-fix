# Changelog

All notable changes to the `discord-fix` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- MIT license file
- Pre-commit hooks for checksum verification and guideline adherence
- GitHub Actions workflow for CI/CD
- Comprehensive README with troubleshooting guide

### Fixed
- Script syntax errors (curly quotes)
- `pgrep` now correctly detects `Discord` process (capital D)
- Removed dead python/perl code (jq is required dependency)
- Added `procps-ng` dependency for `pgrep`
- Timestamped backups to prevent overwrites
- Fixed hook/install script duplication

### Removed
- Dead code for python3/perl JSON editing (jq is required)

## [1.0.0] - 2026-05-05

### Added
- Initial release
- Pacman hook that triggers on Discord install/upgrade
- Automatic `SKIP_HOST_UPDATE=true` configuration
- Support for multi-user systems
- JSON validation and beautification
- Backup creation before modifications
- Restart notification if Discord is running

[Unreleased]: https://github.com/weselben/discord-fix/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/weselben/discord-fix/releases/tag/v1.0.0
