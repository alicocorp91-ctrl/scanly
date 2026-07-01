# Scanly - Profesyonel Belge Tarama Uygulaması

**CamScanner & Simple Scanner kalitesinde, tamamen ücretsiz, yerel depolama odaklı profesyonel belge tarama uygulaması.**

## ✨ Özellikler

### 📸 Gelişmiş Kamera
- Profesyonel kamera vizörü ile belge kenar algılama
- Otomatik kırpma ve perspektif düzeltme
- Galeri'den fotoğraf seçme
- Çok sayfalı tarama desteği

### 🎨 Profesyonel Filtreler
- Orijinal
- Magic Color
- Siyah-Beyaz (B&W)
- Grayscale
- Lightning

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

## 🛠️ Teknoloji Yığını

- **Framework:** Flutter 3.22+
- **State Management:** Riverpod
- **Veritabanı:** Hive
- **Kamera:** camera + image_picker
- **OCR:** google_mlkit_text_recognition
- **PDF:** pdf + printing

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.22 veya更高
- Android Studio / VS Code
- Android cihaz veya emulator (API 24+)

### Adımlar

```bash
# Projeyi klonlayın
git clone <repo-url>
cd scanly

# Bağımlılıkları yükleyin
flutter pub get

# Hive adapter'larını oluşturun
flutter packages pub run build_runner build

# Android için APK oluşturun
flutter build apk --release

# Veya debug için
flutter run
```

## 📱 APK Çıktısı

`build/app/outputs/flutter-apk/app-release.apk`

## 📂 Proje Yapısı

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── services/
│   ├── providers/
│   └── utils/
├── features/
│   ├── onboarding/
│   ├── camera/
│   ├── editor/
│   ├── documents/
│   ├── ocr/
│   └── pdf/
├── shared/
│   ├── models/
│   └── widgets/
└── main.dart
```

## ✅ Tamamlanan Özellikler

- [x] Onboarding (3 sayfa)
- [x] Kamera + Belge overlay
- [x] Gelişmiş görüntü editörü
- [x] Filtreler
- [x] Çok sayfalı tarama
- [x] Sayfa sürükle-bırak sıralama
- [x] PDF oluşturma ve paylaşım
- [x] Hive veritabanı
- [x] Klasörleme sistemi
- [x] Arama
- [x] Çevrimdışı OCR
- [x] Material 3 + Dark Mode
- [x] İzin yönetimi
- [x] Hata yönetimi

## 📝 Notlar

- Tüm veriler cihaz üzerinde saklanır.
- Reklam veya premium kısıtlaması yoktur.
- Tamamen ücretsizdir.

---

**Geliştirici:** Arena.ai Agent Mode  
**Versiyon:** 1.0.0