# 🚀 Yavaş Bilgisayar İçin APK Oluşturma Yöntemi

Bilgisayarınız yavaş olduğu için **GitHub Actions** kullanarak **ücretsiz** ve **otomatik** şekilde APK oluşturacağız.

Bu yöntemle bilgisayarınıza **hiçbir şey kurmanıza gerek yok**.

---

## 📌 ADIM ADIM TALİMATLAR

### 1. GitHub Hesabı Oluştur (Zaten varsa geç)

- [github.com](https://github.com) adresine git
- Ücretsiz hesap oluştur

### 2. Yeni Repository Oluştur

1. GitHub'a giriş yap
2. Sağ üstteki **"+"** → **New repository**
3. Repository adı yaz: `scanly`
4. **Public** seç (ücretsiz olduğu için)
5. **Create repository**'ye tıkla

### 3. Projeyi GitHub'a Yükle (En Kolay Yöntem)

#### Yöntem A: GitHub Desktop ile (Önerilen)

1. [GitHub Desktop](https://desktop.github.com/) indir ve kur
2. GitHub Desktop'ı aç
3. **Clone a repository** → **URL** sekmesine şu adresi yapıştır:
   ```
   https://github.com/KULLANICI_ADIN/scanly.git
   ```
4. **Clone**'a tıkla
5. Bilgisayarındaki `scanly` klasörünü GitHub Desktop'a sürükle
6. **Commit to main** → **Push origin** yap

#### Yöntem B: Web üzerinden (Daha Kolay)

1. GitHub'da repository'ni aç
2. **Add file** → **Upload files**
3. Tüm `scanly` klasöründeki dosyaları sürükle-bırak yap
4. **Commit changes**'e tıkla

> **Not:** `.github` klasörünü de mutlaka yükle!

### 4. APK Oluştur

1. GitHub repository'ne git
2. Sol menüden **Actions** sekmesine tıkla
3. **"Build Release APK"** workflow'unu gör
4. **Run workflow** → **Run workflow**'ya tıkla

**İlk seferde yaklaşık 8-12 dakika sürer.**

### 5. APK'yı İndir

Workflow tamamlandığında:

- **Artifacts** bölümünden **`scanly-release-apk`** dosyasını indir
- Veya **Releases** sekmesinden `v1.0.0` sürümünü indir

---

## ✅ Sonuç

Bu yöntemle:
- Bilgisayarına Flutter kurmana gerek yok
- Hiçbir komut çalıştırmana gerek yok
- APK tamamen ücretsiz ve otomatik oluşuyor

---

## 📁 Bu Projede Hazırlanan Dosyalar

- `.github/workflows/build-apk.yml` → Otomatik build workflow'u
- `BUILD_INSTRUCTIONS.md` → Klasik yöntem
- `build_apk.sh` → Otomatik script

---

**Şimdi GitHub'a yükle ve APK'yı al!**

Herhangi bir adımda takılırsan söyle, yardımcı olayım.