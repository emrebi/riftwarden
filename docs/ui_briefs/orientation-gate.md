# GOREV: YATAYA CEVIRME KAPISI TASARIMI VE ANIMASYONU

Once AGENTS.md dosyasini oku.
BU EKRAN ISTISNADIR: uygulama acilisinda DIKEY gorunur. Hem dikey (360x640 dp) hem yatay (640x360 dp) dogru cizilmelidir.

Dosyalar: lib/features/orientation_gate/view/orientation_gate_screen.dart (su an gecici basit gorunum var)
ve gerekirse lib/features/orientation_gate/widgets/ altina parcalar.

DEGISMEYECEKLER:
- OrientationGateScreen public constructor'u
- Controller kullanimi ve akisi: olusturma/start/dispose, MediaQuery orientation kontrolu ile
  onOrientationChanged cagrisi, tum ekran dokununca onTap
- lib/features/orientation_gate/viewmodel/ dosyasini OKU ama DOKUNMA
Sadece gorunumu ve animasyonu yaz.

AMAC: oyuncu ne yapmasi gerektigini 1 saniyede anlasin.
- Ortada bir telefon silueti: dikey durustan saga 90 derece donup yatay olur, kisa bir duraksama, basa doner
  ve tekrar eder (dongu ~2 saniye). Donme yonunu gosteren kavisli bir ok.
- Altinda baslik (rotateTitle) ve ipucu (rotateHint).
- Geri sayim: dairesel ilerleme halkasi (secondsLeft / 10) + rotateAutoIn metni. secondsLeft'i
  ValueListenableBuilder ile oku.
- En altta soluk rotateTapToContinue metni.
- Arka plan oyunun tema gradyani; telefon silueti ve ok AppColors.aetherCyan tonunda, hafif parlama.
- Tek AnimationController, repeat; dispose edilmeli. Animasyon hafif olmali.
- Telefon ve ok CustomPaint veya Transform ile cizilir; resim asset'i kullanma.

Kurallar: ham renk/olcu/TextStyle yok; tum metinler l10n (anahtarlar mevcut); EdgeInsetsDirectional kullan;
lib/shared/widgets ve lib/app/theme dosyalarina dokunma; terminal komutu calistirma.

Kabul: flutter analyze 0 issue; python tools/ui_lint.py TEMIZ; 360x640 ve 640x360'ta tasma yok.
Rapor: AGENTS.md rapor formati.
