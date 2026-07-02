# 🤝 Scanly'a Katkı Sağlama Rehberi

Teşekkürler! Scanly projesine katkıda bulunmak istediğin için memnuniyet duyarız.

Bu belge, projeye nasıl katkıda bulunabileceğini açıklamaktadır.

---

## 📋 İçindekiler

- [Geliştirme Ortamı Kurulumu](#geliştirme-ortamı-kurulumu)
- [Katkı Türleri](#katkı-türleri)
- [Pull Request Süreci](#pull-request-süreci)
- [Kod Standartları](#kod-standartları)
- [Commit Mesajları](#commit-mesajları)

---

## 🛠️ Geliştirme Ortamı Kurulumu

### Gereksinimler

- Flutter **3.22.3** veya更高
- Dart **3.4+**
- Android Studio / VS Code
- JDK 17+

### Kurulum Adımları

```bash
# 1. Projeyi fork'la ve klonla
git clone https://github.com/alicocorp91-ctrl/scanly.git
cd scanly

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Hive adapter'larını oluştur
dart run build_runner build --delete-conflicting-outputs

# 4. Uygulamayı test et
flutter run
```

---

## 🔄 Katkı Türleri

### 1. Bug Raporu

Bir hata bulduysan:

1. **Issues** sekmesinden yeni bir issue aç.
2. Başlıkta net bir özet yaz.
3. Adımları detaylı anlat.
4. Ekran görüntüsü veya video ekle (mümkünse).

### 2. Özellik İsteği

Yeni bir özellik öneriyorsan:

1. Issue oluştur.
2. Özelliğin ne işe yarayacağını açıkla.
3. Varsa örnek ekran görüntüsü ekle.

### 3. Kod Katkısı (Pull Request)

- Küçük düzeltmeler için doğrudan PR açabilirsin.
- Büyük değişiklikler için önce **Issue** aç ve tartış.

---

## 📬 Pull Request Süreci

### Adımlar

1. **Fork** yap.
2. Yeni bir branch oluştur:
   ```bash
   git checkout -b feature/yeni-ozellik
   ```
3. Değişikliklerini yap.
4. Test et:
   ```bash
   flutter test
   ```
5. Commit at:
   ```bash
   git commit -m "feat: yeni özellik eklendi"
   ```
6. Push yap:
   ```bash
   git push origin feature/yeni-ozellik
   ```
7. **Pull Request** oluştur.

### PR Kuralları

- PR başlığı net olmalı.
- Açıklama kısmında ne yaptığını yaz.
- Ekran görüntüsü ekle (UI değişikliği varsa).
- İlgili issue'yu referans ver (`Closes #123`).

---

## 📐 Kod Standartları

### Genel Kurallar

- **Dart** ve **Flutter** kod standartlarına uy.
- `flutter analyze` komutunu çalıştır ve hata olmasın.
- Her public fonksiyon için **dokümantasyon** yaz.

### Dosya Yapısı

- Her özellik kendi klasöründe olmalı (`features/` altında).
- Widget'lar `shared/widgets/` klasöründe tutulmalı.
- Servisler `core/services/` klasöründe olmalı.

### İsimlendirme

- Dosya ve klasör isimleri **snake_case** olmalı.
- Sınıf isimleri **PascalCase** olmalı.
- Değişken ve fonksiyon isimleri **camelCase** olmalı.

### Örnek

```dart
// Doğru
class DocumentCard extends StatelessWidget { ... }

// Yanlış
class document_card extends StatelessWidget { ... }
```

---

## ✍️ Commit Mesajları

Commit mesajları **Conventional Commits** formatında olmalı.

### Format

```
<type>: <description>

[optional body]
```

### Örnekler

| Tür | Açıklama | Örnek |
|-----|---------|-------|
| `feat` | Yeni özellik | `feat: interaktif kırpma eklendi` |
| `fix` | Hata düzeltme | `fix: kamera izni hatası çözüldü` |
| `docs` | Dokümantasyon | `docs: README güncellendi` |
| `refactor` | Kod iyileştirme | `refactor: image_utils iyileştirildi` |
| `style` | Biçimlendirme | `style: kod formatı düzeltildi` |
| `test` | Test ekleme | `test: kırpma widget testi eklendi` |

---

## ✅ PR Kontrol Listesi

PR göndermeden önce kontrol et:

- [ ] `flutter analyze` hatasız çalışıyor
- [ ] `flutter test` geçiyor
- [ ] Kod standartlarına uyulmuş
- [ ] Commit mesajı doğru formatta
- [ ] Ekran görüntüsü eklenmiş (gerekliyse)
- [ ] İlgili issue referans verilmiş

---

## 📞 İletişim

Herhangi bir sorunda:

- GitHub Issues üzerinden iletişime geç
- Veya mevcut Pull Request'lerde yorum yap

---

**Teşekkürler!** Scanly'ı daha iyi hale getirmemize yardımcı olduğun için minnettarız.