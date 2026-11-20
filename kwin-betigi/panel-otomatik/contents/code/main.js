// Panel otomatik gizleme (2026-11-18)
// Geçerli masaüstünde büyütülmüş ya da tam ekran (ve simge durumunda olmayan) en az bir pencere varsa
// TÜM paneller "otomatik gizle" olur (fare alt kenara gelince açılır). Yoksa hepsi "hep görünür".
var son = null;

function buMasaustunde(w) {
    if (w.onAllDesktops) return true;
    var cur = workspace.currentDesktop;
    var d = w.desktops || [];
    for (var i = 0; i < d.length; i++) {
        if (d[i] === cur || (d[i] && cur && d[i].id === cur.id)) return true;
    }
    return false;
}

function kaplıyor(w) {
    if (!w || !w.normalWindow || w.minimized || w.deleted) return false;
    if (!(w.fullScreen || w.maximizeMode === 3)) return false;
    return buMasaustunde(w);
}

function hesapla() {
    var ws = workspace.windowList();
    var gizle = false;
    for (var i = 0; i < ws.length; i++) {
        if (kaplıyor(ws[i])) { gizle = true; break; }
    }
    if (gizle === son) return;
    son = gizle;
    // Normal durumda: sadece ortadaki panel ekran kenarında yer ayırır ("none"); yandakiler yer ayırmadan
    // pencerelerden kaçar ("dodgewindows"; bu Plasma sürümünde betikten "windowsgobelow" ayarlanamıyor). Hepsi "none" olunca Wayland'de ayrılan şeritler üst üste
    // biner ve orta panel yukarı itilir.
    var js = gizle
        ? "panels().forEach(function(p){ if (p.hiding != 'autohide') p.hiding = 'autohide'; });"
        : "panels().forEach(function(p){ var m = (p.alignment == 'center') ? 'none' : 'dodgewindows';" +
          " if (p.hiding != m) p.hiding = m; });";
    callDBus("org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell", "evaluateScript", js);
}

function bagla(w) {
    var sinyaller = ["minimizedChanged", "fullScreenChanged", "maximizedChanged", "desktopsChanged"];
    for (var i = 0; i < sinyaller.length; i++) {
        try { w[sinyaller[i]].connect(hesapla); } catch (e) { }
    }
}

var hepsi = workspace.windowList();
for (var i = 0; i < hepsi.length; i++) bagla(hepsi[i]);
workspace.windowAdded.connect(function (w) { bagla(w); hesapla(); });
workspace.windowRemoved.connect(function () { hesapla(); });
workspace.currentDesktopChanged.connect(hesapla);
hesapla();
