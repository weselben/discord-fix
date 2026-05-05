#!/bin/bash
set -e

WS="$1"
if [[ -z "$WS" ]]; then
  echo "Usage: $0 /path/to/workspace"
  exit 1
fi

pacman -Syu --noconfirm
pacman -S --noconfirm base-devel jq procps-ng discord

useradd -m builder
echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder

chown -R builder:builder "$WS"
cd "$WS"
su builder -c "makepkg -s --noconfirm"

for f in *.pkg.tar.zst; do
  sha256sum "$f" > "${f}.sha256"
  sha512sum "$f" > "${f}.sha512"
done

# Fix ownership so host can access
chown -R $(stat -c "%u:%g" "$WS") "$WS"
