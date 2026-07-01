#!/bin/bash

# ==============================================
# Scanly - Professional Document Scanner
# Automated Release APK Builder
# ==============================================

set -e

echo "🚀 Scanly APK Builder başlatılıyor..."
echo "======================================"

# 1. Flutter temizliği
echo "🧹 Flutter temizleniyor..."
flutter clean

# 2. Bağımlılıkları yükle
echo "📦 Bağımlılıklar yükleniyor..."
flutter pub get

# 3. Hive adapter'larını oluştur
echo "🔧 Hive adapter'ları oluşturuluyor..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 4. Release APK oluştur
echo "📱 Release APK oluşturuluyor..."
flutter build apk --release

# 5. APK'yı kolay erişilebilir konuma kopyala
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
OUTPUT_NAME="scanly-v1.0.0-release.apk"

if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$OUTPUT_NAME"
    echo ""
    echo "✅ BAŞARILI!"
    echo "======================================"
    echo "📦 APK Dosyası: $OUTPUT_NAME"
    echo "📍 Konum: $(pwd)/$OUTPUT_NAME"
    echo "📊 Boyut: $(du -h "$OUTPUT_NAME" | cut -f1)"
    echo ""
    echo "Uygulamayı cihazınıza yükleyebilirsiniz."
else
    echo "❌ APK oluşturulamadı!"
    exit 1
fi