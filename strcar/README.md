Strcar – Giriş Ekranı (Expo React Native)

Kurulum

1) Bağımlılıkları yükleyin:

```bash
cd /workspace/strcar
npm install
```

2) Geliştirme sunucusunu başlatın:

```bash
npm run android
# veya
npm run ios
# veya
npm run web
```

Özellikler

- Degrade arkaplanlı Hoş Geldiniz ekranı
- Bluetooth/Wi‑Fi açma uyarısı (mock)
- Marka/Model/Yıl seçimleri ve yerel kayıt
- OBD tarama ilerleme çubuğu ve cihaz listesi (mock)
- Bağlantı başarıyla tamamlanınca "Devam Et" ile Ana Menü

İzinler

- iOS: `NSBluetoothAlwaysUsageDescription`, `NSLocationWhenInUseUsageDescription`
- Android: Bluetooth ve Konum izinleri `app.json` altında tanımlıdır

Not

- OBD taraması ve bağlantı akışı bu sürümde simüle edilmiştir. Gerçek cihaz entegrasyonu için uygun BLE/Wi‑Fi SDK’sı eklenmelidir.
