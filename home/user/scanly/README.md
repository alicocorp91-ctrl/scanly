# 📱 Scanly - Profesyonel Belge Tarama Uygulaması

**CamScanner ve Simple Scanner kalitesinde, tamamen ücretsiz, yerel depolama odaklı profesyonel belge tarama uygulaması.**

[![Flutter](https://img.shields.io/badge/Flutter-3.22.3-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-orange.svg)]()

---

## ✨ Özellikler

### 📸 Gelişmiş Kamera
- Profesyonel kamera vizörü ile belge kenar algılama
- **İnteraktif 4 köşeli kırpma** (sürükle-bırak)
- Otomatik kenar algılama önerisi
- Perspektif düzeltme
- Çok sayfalı tarama desteği

### 🎨 Profesyonel Filtreler
- **Magic Color** - Renkleri canlandırır, belgeyi parlatır
- **B&W** - Yüksek kontrastlı siyah-beyaz (metin odaklı)
- **Grayscale** - Normal gri tonlama
- **Lightning** - Gölgeleri yok eder, aydınlatır
- Orijinal

### 📄 PDF ve Paylaşım
- A4 ve Letter sayfa boyutu desteği
- PDF olarak paylaşım
- JPEG olarak paylaşım
- Filigransız, temiz çıktı

### 📁 Klasörleme ve Yönetim
- Sınırsız klasör oluşturma
- Sürükle-bırak sayfa sıralama
- Belge yeniden adlandırma ve taşıma
- Güçlü arama özelliği

### 🔍 Çevrimdışı OCR
- Cihaz üzerinde metin tanıma
- Kopyalama ve TXT paylaşımı

### 🌓 Modern UI/UX
- Material 3 tasarım
- Karanlık / Aydınlık mod
- Haptic feedback
- Şık onboarding

---

## 🛠️ Teknoloji Yığını

| Teknoloji | Kullanım |
|---------|---------|
| **Framework** | Flutter 3.22.3 |
| **State Management** | Riverpod |
| **Veritabanı** | Hive |
| **Kamera** | camera + image_picker |
| **Görüntü İşleme** | image paketi |
| **OCR** | google_mlkit_text_recognition |
| **PDF** | pdf + printing |
| **İzinler** | permission_handler |

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler

- Flutter SDK **3.22.3** veya更高
- Dart SDK **3.4+**
- Android Studio / VS Code + Flutter eklentisi
- Android cihaz veya emulator (API 24+)
- JDK 17+

### Adımlar

```bash
# 1. Projeyi klonla
git clone https://github.com/alicocorp91-ctrl/scanly.git
cd scanly

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Hive adapter'larını oluştur (ZORUNLU)
dart run build_runner build --delete-conflicting-outputs

# 4. Uygulamayı çalıştır
flutter run
```

### Release APK Oluşturma

```bash
# Tek komutla release APK oluştur
flutter build apk --release

# Veya ABI bazlı (daha küçük boyut)
flutter build apk --release --split-per-abi
```

**APK Konumu:**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🤖 GitHub Actions ile Otomatik APK Oluşturma

Bu proje **GitHub Actions** ile otomatik olarak release APK oluşturmaktadır.

### Nasıl Çalışır?

1. GitHub reposuna gir
2. **Actions** sekmesine tıkla
3. **"Build Release APK"** workflow'unu seç
4. **"Run workflow"** butonuna tıkla

### Artifact İndirme

Workflow tamamlandıktan sonra:
- **Artifacts** bölümünden **`scanly-release-apk`** dosyasını indir
- Dosya `.zip` olarak iner

---

## 📂 Proje Yapısı

```
scanly/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── services/
│   │   ├── providers/
│   │   └── utils/
│   ├── features/
│   │   ├── onboarding/
│   │   ├── camera/
│   │   ├── editor/
│   │   ├── documents/
│   │   ├── ocr/
│   │   └── settings/
│   └── shared/
│       ├── models/
│       └── widgets/
├── assets/
│   ├── images/
│   └── icons/
├── .github/workflows/
│   └── main.yml
├── pubspec.yaml
└── README.md
```

---

## 🔧 Geliştirme Notları

### Önemli Komutlar

```bash
# Hive adapter'larını yeniden oluştur
dart run build_runner build --delete-conflicting-outputs

# Temizle ve yeniden yükle
flutter clean && flutter pub get

# Sadece Android için build
flutter build apk --release
```

### Mimari

- **Feature-First + Clean Architecture** kullanılmıştır
- Her özellik kendi klasöründe izole edilmiştir
- Riverpod ile state yönetimi yapılmaktadır
- Hive ile yerel veritabanı kullanılmaktadır

### Paket Versiyonları

Tüm paketler `pubspec.yaml` dosyasında belirtilmiştir. Yeni paket eklerken şu kurallara uyun:

- `camera` paketi: `^0.9.4+21` (daha stabil)
- `riverpod` paketi: `^2.5.1`
- `hive` paketi: `^2.2.3`

---

## 📌 Gelecek Geliştirmeler

- [ ] Daha gelişmiş otomatik kenar algılama (ML tabanlı)
- [ ] PDF filigran özelliği
- [ ] Toplu silme ve taşıma işlemleri
- [ ] OCR iyileştirmeleri (çoklu sayfa)
- [ ] Bulut yedekleme (opsiyonel)
- [ ] iOS desteği

---

## 📝 Lisans

Bu proje MIT lisansı altında yayınlanmıştır.

---

## 👨‍💻 Geliştirici

**Arena.ai Agent Mode** tarafından geliştirilmiştir.

---

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. GitHub Issues bölümünden bildirin
2. Veya mevcut workflow'ları kontrol edin

---

**Scanly** - Profesyonel belge tarama, tamamen ücretsiz.