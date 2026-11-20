#!/bin/bash
# kur.sh'ın yaptıklarını geri alır.  Kullanım:  bash geri-al.sh ~/.local/share/tokyo-night-kde-yedek/<tarih>
Y=${1:?yedek klasörünü ver (kur.sh sonunda yazdı)}
[ -d "$Y" ] || { echo "yok: $Y"; exit 1; }
for f in kdeglobals plasmarc breezerc kscreenlockerrc Kvantum/kvantum.kvconfig; do
  [ -e "$Y/$f" ] && cp -a "$Y/$f" "$HOME/.config/$f"
done
[ -e "$Y/breezerc" ] || rm -f "$HOME/.config/breezerc"
cs=$(kreadconfig6 --file kdeglobals --group General --key ColorScheme); plasma-apply-colorscheme "${cs:-BreezeDark}"
pt=$(kreadconfig6 --file plasmarc --group Theme --key name); plasma-apply-desktoptheme "${pt:-default}"
[ -s "$Y/blackbox-theme-dark.txt" ] && gsettings set com.raggesilver.BlackBox theme-dark "$(tr -d "'" < "$Y/blackbox-theme-dark.txt")"
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null
echo "Geri alındı. Duvar kağıdını ve başlat simgesini elle değiştirebilirsin (sağ tık > yapılandır)."
