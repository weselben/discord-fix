#!/bin/bash
set -euo pipefail

echo "=== INSTALLING DEPENDENCIES ==="
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel git jq procps-ng curl

echo "=== MOCKING DISCORD (for PKGBUILD check) ==="
mkdir -p /usr/bin/
echo '#!/bin/bash' > /usr/bin/discord
chmod +x /usr/bin/discord

echo "=== BUILDING PACKAGE (as root) ==="
makepkg -s --noconfirm

echo "=== TESTING SCRIPT ==="
# Test 1: Syntax
bash -n discord-fix-script.sh || { echo "SYNTAX ERROR"; exit 1; }

# Test 2: Create test environment
TEST_HOME=$(mktemp -d)
mkdir -p "$TEST_HOME/.config/discord"

# Test 3: Configure incorrect settings
echo '{"SKIP_HOST_UPDATE": false}' > "$TEST_HOME/.config/discord/settings.json"
echo "Test 1: Configuring incorrect settings..."
HOME="$TEST_HOME" ./discord-fix-script.sh 2>&1 | grep -q "Updated" || { echo "TEST FAILED: Didn't update settings"; exit 1; }
jq -e '.SKIP_HOST_UPDATE == true' "$TEST_HOME/.config/discord/settings.json" >/dev/null || { echo "TEST FAILED: SKIP_HOST_UPDATE not true"; exit 1; }
echo "✓ Test 1 passed: Settings updated correctly"

# Test 4: Run again (should skip)
HOME="$TEST_HOME" ./discord-fix-script.sh 2>&1 | grep -q "already correctly configured" || { echo "TEST FAILED: Didn't skip already-configured settings"; exit 1; }
echo "✓ Test 2 passed: Skipped already-configured settings"

# Test 5: Backup created
ls "$TEST_HOME/.config/discord/settings.json.discord-fix-backup-"* >/dev/null 2>&1 || { echo "TEST FAILED: Backup not created"; exit 1; }
echo "✓ Test 3 passed: Backup created"

rm -rf "$TEST_HOME"
echo "=== ALL TESTS PASSED ==="

echo "=== GENERATING CHECKSUMS ==="
mkdir -p release
for file in *.pkg.tar.*; do
  sha256sum "$file" > "release/${file}.sha256"
  sha512sum "$file" > "release/${file}.sha512"
done

echo "=== CREATING SINGLE ARTIFACT ==="
cp *.pkg.tar.* release/
cp discord-fix-script.sh release/
cp PKGBUILD release/
tar -czf discord-fix-release.tar.gz -C release .
echo "Created discord-fix-release.tar.gz"
ls -la discord-fix-release.tar.gz
EOF'
echo "Build script updated"