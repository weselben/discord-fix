# Maintainer: weselben <bengottwaldi04@gmail.com>
pkgname=discord-fix
pkgver=0.0.1
pkgrel=1
pkgdesc="Fixes Discord's forced update block on Arch by auto-setting SKIP_HOST_UPDATE in user settings.json"
arch=('any')
url='https://github.com/weselben/discord-fix'
license=('MIT')
depends=('discord' 'bash' 'jq' 'procps-ng')
install=discord-fix.install
source=("discord-fix-script.sh"
        "discord-fix.hook"
        "LICENSE")
sha512sums=('cec8f2f43c15b7b5ba71ac8ef438161d99aea500618985be1f5e23e1ee3e6c519c2673f052cb2907b71b99ba172943b3a265c37071c90a89d10cf5332581f79f'
            'd11ad03b7fa73193db9f76e8272d3c1d5c8f177ab52c5c75415b914910502077026af1a2d6c7599455cef946d461102c42621f2ddce2bbee2e9669a522553d32'
            'b1a28d1d68d9f52d70a9a06d1ddc5992b634f8ce9cc4cadd1bc77af543ea2f6c93eab760ff1d81479a38f9f402256e7dbe663a108a38bbe08806b2e6b060ca2e')

package() {
  install -Dm755 "$srcdir/discord-fix-script.sh" "$pkgdir/usr/lib/discord-fix/discord-fix-script.sh"
  install -Dm644 "$srcdir/discord-fix.hook" "$pkgdir/usr/share/libalpm/hooks/discord-fix.hook"
  install -Dm644 "$srcdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
