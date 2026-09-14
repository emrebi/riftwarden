# GOREV: SONUC EKRANINI YATAYA UYARLA

Once AGENTS.md dosyasini oku. Uygulama artik YATAY. Hedef en kucuk ekran 640x360 dp.

Dosyalar: lib/features/result/view/result_screen.dart ve lib/features/result/widgets/
ResultScreen'in public constructor'u ve result_data.dart dosyasi DEGISMEZ.

Yeni yerlesim:
- Sol yarim: zafer veya yenilgi basligi, level etiketi, (yenilgide) dalga ilerlemesi, (zaferde) odul paneli.
- Sag yarim: aksiyon butonlari dikey sirada: varsa reklam butonu, primary buton (DEVAM / TEKRAR DENE), ana menu.
- Primary buton en baskin kalir.
- MediaQuery.viewPadding.left/right uygulanmali.

Kurallar:
- canWatchAd false iken reklam butonu HIC cizilmez kurali korunur.
- Hiz kurali korunur: zorunlu bekleme ve uzun animasyon yok.
- lib/shared/widgets ve lib/app/theme dosyalarina dokunma. Terminal calistirma.
- Yeni metin gerekirse sadece app_en.arb dosyasina ekle.

Kabul: flutter analyze 0 issue; ui_lint TEMIZ. Rapor: AGENTS.md formati.
