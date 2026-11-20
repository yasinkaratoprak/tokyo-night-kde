#!/bin/bash
# Tokyo Night KDE paketi — kurulum (KDE Plasma 6). Root gerekmez; her ayarın önce yedeği alınır.
# Kullanım:  bash kur.sh
set -u
D=$(cd "$(dirname "$0")" && pwd)
Y="$HOME/.local/share/tokyo-night-kde-yedek/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$Y"
for f in kdeglobals plasmarc breezerc kscreenlockerrc Kvantum/kvantum.kvconfig; do
  [ -e "$HOME/.config/$f" ] && { mkdir -p "$Y/$(dirname "$f")"; cp -a "$HOME/.config/$f" "$Y/$f"; }
done
command -v gsettings >/dev/null && gsettings get com.raggesilver.BlackBox theme-dark > "$Y/blackbox-theme-dark.txt" 2>/dev/null
echo "Yedek: $Y"

echo "1) Renk düzeni"
mkdir -p ~/.local/share/color-schemes
cp "$D/renkler/TokyoNight.colors" ~/.local/share/color-schemes/
plasma-apply-colorscheme TokyoNight

echo "2) Plasma teması (renk düzenine uyan Breeze)"
plasma-apply-desktoptheme default

echo "3) Pencere gölgeleri"
kwriteconfig6 --file breezerc --group Common --key ShadowSize ShadowLarge
kwriteconfig6 --file breezerc --group Common --key ShadowStrength 220
kwriteconfig6 --file breezerc --group Common --key OutlineIntensity OutlineLow
kwriteconfig6 --file breezerc --group Windeco --key DrawTitleBarSeparator false
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null

echo "4) Kvantum (yuvarlak düğmeler)"
mkdir -p ~/.config/Kvantum
cp -r "$D/kvantum/TokyoNight" ~/.config/Kvantum/
printf '[General]\ntheme=TokyoNight\n' > ~/.config/Kvantum/kvantum.kvconfig
if [ -d /usr/share/Kvantum ] || command -v kvantummanager >/dev/null; then
  kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
  echo "   uygulama stili: kvantum (açık programlar yeniden açılınca görür)"
else
  echo "   Kvantum kurulu değil, stil değiştirilmedi. Kurmak için: sudo apt install qt-style-kvantum qt-style-kvantum-themes"
  echo "   sonra bu betiği tekrar çalıştır."
fi

echo "5) Terminal renkleri"
mkdir -p ~/.local/share/konsole ~/.local/share/blackbox/schemes
cp "$D/terminal/konsole-TokyoNight.colorscheme" ~/.local/share/konsole/TokyoNight.colorscheme
cp "$D/terminal/blackbox-tokyo-night.json" ~/.local/share/blackbox/schemes/tokyo-night.json
if gsettings list-schemas 2>/dev/null | grep -qx com.raggesilver.BlackBox; then
  gsettings set com.raggesilver.BlackBox theme-dark 'Tokyo Night'
  echo "   Black Box: Tokyo Night (programı tamamen kapatıp açınca görünür)"
fi
echo "   Konsole: Ayarlar > Profili düzenle > Görünüm > 'Tokyo Night' seç"

echo "6) Duvar kağıdı + kilit ekranı"
W="$HOME/.local/share/wallpapers/TokyoNight"; mkdir -p "$W"
cp "$D"/duvar-kagitlari/*.png "$W/"
plasma-apply-wallpaperimage "$W/tokyo-night-mavi-mor.png"
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$W/tokyo-night-mavi-mor.png"
echo "   Diğer renkler $W içinde (sağ tık > Masaüstünü yapılandır)"

echo "7) Başlat menüsü simgesi (hilal)"
mkdir -p ~/.local/share/icons
cp "$D/simgeler/tokyo-baslat.svg" ~/.local/share/icons/
qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript "panels().forEach(function(p){p.widgets().forEach(function(w){
  if(w.type=='org.kde.plasma.kickoff'){w.currentConfigGroup=['General'];w.writeConfig('icon','$HOME/.local/share/icons/tokyo-baslat.svg');}});});" 2>/dev/null

echo
echo "Bitti. İsteğe bağlı parçalar için README.md'ye bak (komut satırı, ada paneller, panel gizleme, Obsidian, VS Code)."
echo "Geri almak için: bash $D/geri-al.sh \"$Y\""
