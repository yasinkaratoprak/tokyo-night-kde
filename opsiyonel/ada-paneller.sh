#!/bin/bash
# Alttaki tek paneli 3 yüzen "ada"ya böler: sol = başlat + masaüstleri, orta = görev çubuğu, sağ = tepsi + saat.
# Sabitlenmiş uygulamalar kopyalanır. Önce panel ayar dosyasının yedeği alınır.
# Varsayım: altta tek panel var (Plasma varsayılanı). Farklı bir düzenin varsa çalıştırma.
F=~/.config/plasma-org.kde.plasma.desktop-appletsrc
cp -a "$F" "$F.ada-yedek" && cp -a ~/.config/plasmashellrc ~/.config/plasmashellrc.ada-yedek
echo "Yedek: $F.ada-yedek  (geri almak: plasmashell'i durdur, yedekleri geri kopyala, başlat)"
qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript '
var ps = panels().filter(function(p){ return p.location=="bottom"; });
if (ps.length != 1) { print("HATA: altta tam 1 panel bekleniyordu, " + ps.length + " var; hiçbir şey değişmedi\n"); }
else {
  var eski = ps[0], launchers = "", kickIcon = "";
  eski.widgets().forEach(function(w){ w.currentConfigGroup=["General"];
    if(w.type=="org.kde.plasma.icontasks"||w.type=="org.kde.plasma.taskmanager") launchers = w.readConfig("launchers","");
    if(w.type=="org.kde.plasma.kickoff") kickIcon = w.readConfig("icon",""); });
  function ada(h){ var p=new Panel; p.location="bottom"; p.alignment=h; p.lengthMode="fit"; p.floating=true; p.hiding="dodgewindows"; p.height=44; return p; }
  var sol=ada("left"); var k=sol.addWidget("org.kde.plasma.kickoff"); if(kickIcon){k.currentConfigGroup=["General"];k.writeConfig("icon",kickIcon);}
  var pg=sol.addWidget("org.kde.plasma.pager"); pg.currentConfigGroup=["General"]; pg.writeConfig("displayedText","None");
  var orta=ada("center"); var t=orta.addWidget("org.kde.plasma.icontasks"); t.currentConfigGroup=["General"]; t.writeConfig("launchers",launchers);
  eski.widgets().forEach(function(w){ if(["org.kde.plasma.kickoff","org.kde.plasma.pager","org.kde.plasma.icontasks","org.kde.plasma.taskmanager","org.kde.plasma.marginsseparator"].indexOf(w.type)>=0) w.remove(); });
  eski.alignment="right"; eski.lengthMode="fit"; eski.floating=true; eski.height=44;
  print("tamam\n");
}'
echo "Görev çubuğunun sabitlemeleri görünmezse: systemctl --user restart plasma-plasmashell"
