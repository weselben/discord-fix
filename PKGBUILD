# Maintainer: weselben <bengottwaldi04@gmail.com>
pkgname=discord-fix
pkgver=1.0.0
pkgrel=1
pkgdesc="Fixes Discord's forced update block on Arch by auto-setting SKIP_HOST_UPDATE in user settings.json"
arch=('any')
url='https://github.com/weselben/discord-fix'
license=('MIT')
depends=('discord' 'bash' 'jq')
install=discord-fix.install
source=("discord-fix-script.sh"
        "discord-fix.hook")
sha512sums=('ffd9aa093fec8e51f7b51e90f9c4c38d378cc4e8c87d55bdfab539caf8a003d0c7338c540eeac1066bf9e84f5506a9121e36f9b02838ad294eb4e25d45ed92ba'
            'd11ad03b7fa73193db9f76e8272d3c1d5c8f177ab52c5c75415b914910502077026af1a2d6c7599455cef946d461102c42621f2ddce2bbee2e9669a522553d32')

package() {
  install -Dm755 "$srcdir/discord-fix-script.sh" "$pkgdir/usr/lib/discord-fix/discord-fix-script.sh"
  install -Dm644 "$srcdir/discord-fix.hook" "$pkgdir/usr/share/libalpm/hooks/discord-fix.hook"
}
