#!/bin/bash
# KWin betiği: tam ekran / büyütülmüş pencere varken TÜM paneller otomatik gizlenir (alt kenara fareyle gelince açılır);
# yoksa ortadaki panel hep görünür, yandakiler pencerelerden kaçar. Ada panellerle birlikte kullanılmak için yazıldı.
# Kaldırmak: kwriteconfig6 --file kwinrc --group Plugins --key panel-otomatikEnabled false && qdbus6 org.kde.KWin /KWin reconfigure
D=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p ~/.local/share/kwin/scripts
cp -r "$D/kwin-betigi/panel-otomatik" ~/.local/share/kwin/scripts/
kwriteconfig6 --file kwinrc --group Plugins --key panel-otomatikEnabled true
qdbus6 org.kde.KWin /KWin reconfigure
echo "Yüklendi: $(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.isScriptLoaded panel-otomatik)"
