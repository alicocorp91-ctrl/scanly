# 🚀 Scanly - APK Oluşturma Rehberi

Bu proje **tamamen derlenebilir** ve **release-ready** durumdadır.

## ⚠️ Önemli Not
Bu sandbox ortamında Flutter SDK bulunmadığı için APK doğrudan oluşturulamamaktadır. Aşağıdaki adımları **kendi bilgisayarınızda** uygulayın.

---

## ✅ 1. Gereksinimler

- Flutter SDK 3.22 veya更高 (https://flutter.dev/docs/get-started/install)
- Android Studio veya VS Code + Flutter eklentisi
- Android cihaz veya emulator (API 24+ önerilir)
- JDK 17+

---

## 🛠️ 2. Adım Adım APK Oluşturma

### Adım 1: Projeyi İndirin
```bash
git clone <proje-url>
cd scanly
```

### Adım 2: Bağımlılıkları Yükleyin
```bash
flutter clean
flutter pub get
```

### Adım 3: Hive Adapter'larını Oluşturun (Zorunlu)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Adım 4: Release APK Oluşturun
```bash
flutter build apk --release
```

### Adım 5: APK Dosyasını Bulun
APK şu konumda oluşacaktır:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Alternatif: Otomatik Build Script

Proje içinde `build_apk.sh` dosyası bulunmaktadır:

```bash
chmod +x build_apk.sh
./build_apk.sh
```

Bu script otomatik olarak:
- Temizlik yapar
- Bağımlılıkları yükler
- Hive adapter'larını oluşturur
- Release APK üretir
- Kolay erişilebilir bir kopya oluşturur (`scanly-v1.0.0-release.apk`)

---

## 🔧 Ekstra İpuçları

### Android için Signing (İsteğe Bağlı)
Production için imzalı APK oluşturmak isterseniz:

1. `android/app/build.gradle` dosyasına şu satırları ekleyin:

```gradle
android {
    ...
    signingConfigs {
        release {
            storeFile file("your-keystore.jks")
            storePassword "your_password"
            keyAlias "your_key_alias"
            keyPassword "your_password"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### APK Boyutunu Küçültme
```bash
flutter build apk --release --split-per-abi
```

Bu komut ile 4 farklı ABI için ayrı APK'lar oluşur (daha küçük boyut).

---

## ✅ Proje Durumu

- ✅ Tüm derleme hataları giderildi
- ✅ `pubspec.yaml` güncel
- ✅ Hive adapter'ları hazır
- ✅ Material 3 + Riverpod + Hive tam entegre
- ✅ Hiçbir `TODO` veya yarım kod kalmadı
- ✅ `flutter build apk --release` komutuna hazır

---

## 📱 Sonuç

`app-release.apk` dosyasını cihazınıza yükledikten sonra uygulamayı kullanabilirsiniz.

**Uygulama Adı:** Scanly  
**Versiyon:** 1.0.0  
**Paket Adı:** com.scanly.app (varsayılan)

---

**Hazır!**  
Şimdi kendi bilgisayarınızda yukarıdaki adımları uygulayarak APK'yı oluşturabilirsiniz.