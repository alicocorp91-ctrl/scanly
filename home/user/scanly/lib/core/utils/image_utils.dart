import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:scanly/core/constants/app_constants.dart';

class ImageUtils {
  /// Compress and resize image for storage
  static Future<String> compressAndSaveImage(String originalPath, {bool createThumbnail = false}) async {
    final file = File(originalPath);
    final bytes = await file.readAsBytes();

    img.Image? image = img.decodeImage(bytes);
    if (image == null) return originalPath;

    // Resize if too large
    if (image.width > AppConstants.maxImageWidth) {
      image = img.copyResize(
        image,
        width: AppConstants.maxImageWidth,
        interpolation: img.Interpolation.linear,
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';

    final compressedBytes = img.encodeJpg(image, quality: AppConstants.jpegQuality);
    await File(savedPath).writeAsBytes(compressedBytes);

    return savedPath;
  }

  /// Create a smaller thumbnail version
  static Future<String?> createThumbnail(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      final thumbnail = img.copyResize(image, width: 300);

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${dir.path}/$fileName';

      final thumbBytes = img.encodeJpg(thumbnail, quality: 75);
      await File(savedPath).writeAsBytes(thumbBytes);

      return savedPath;
    } catch (e) {
      return null;
    }
  }

  /// Delete image file from storage
  static Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ==================== GERÇEK FİLTRELER ====================

  /// Magic Color - Renkleri canlandırır, belgeyi parlatır
  static Future<String> applyMagicColor(String inputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return inputPath;

    // Kontrast ve parlaklık artırma
    image = img.adjustColor(
      image,
      contrast: 1.15,
      brightness: 1.08,
      saturation: 1.25,
    );

    return await _saveProcessedImage(image, 'magic');
  }

  /// Siyah-Beyaz (B&W) - Yüksek kontrastlı metin odaklı
  static Future<String> applyBlackAndWhite(String inputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return inputPath;

    // Gri tonlama + yüksek kontrast
    image = img.grayscale(image);
    image = img.adjustColor(image, contrast: 1.4, brightness: 1.05);

    return await _saveProcessedImage(image, 'bw');
  }

  /// Grayscale - Normal gri tonlama
  static Future<String> applyGrayscale(String inputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return inputPath;

    image = img.grayscale(image);
    return await _saveProcessedImage(image, 'grayscale');
  }

  /// Lightning - Gölgeleri yok eder, aydınlatma
  static Future<String> applyLightning(String inputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return inputPath;

    // Parlaklık ve kontrast artırma + hafif keskinleştirme
    image = img.adjustColor(
      image,
      brightness: 1.25,
      contrast: 1.12,
    );
    image = img.contrast(image, contrast: 1.1);

    return await _saveProcessedImage(image, 'lightning');
  }

  /// Orijinal resmi döndürür
  static Future<String> applyOriginal(String inputPath) async {
    return inputPath;
  }

  /// Perspektif Düzeltme (Kırpılan alanı düzleştirir)
  static Future<String> applyPerspectiveCorrection(String inputPath, List<Offset> normalizedCorners) async {
    final bytes = await File(inputPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return inputPath;

    if (normalizedCorners.length != 4) return inputPath;

    // Köşeleri piksel koordinatlarına çevir
    final int w = image.width;
    final int h = image.height;

    final srcTopLeft = img.Point(
      (normalizedCorners[0].dx * w).toInt(),
      (normalizedCorners[0].dy * h).toInt(),
    );
    final srcTopRight = img.Point(
      (normalizedCorners[1].dx * w).toInt(),
      (normalizedCorners[1].dy * h).toInt(),
    );
    final srcBottomRight = img.Point(
      (normalizedCorners[2].dx * w).toInt(),
      (normalizedCorners[2].dy * h).toInt(),
    );
    final srcBottomLeft = img.Point(
      (normalizedCorners[3].dx * w).toInt(),
      (normalizedCorners[3].dy * h).toInt(),
    );

    // Hedef dikdörtgen (A4 benzeri oran)
    final int targetWidth = w;
    final int targetHeight = (w * 1.414).toInt(); // A4 oranı

    final destTopLeft = img.Point(0, 0);
    final destTopRight = img.Point(targetWidth - 1, 0);
    final destBottomRight = img.Point(targetWidth - 1, targetHeight - 1);
    final destBottomLeft = img.Point(0, targetHeight - 1);

    // Basit perspektif düzeltme (yaklaşık)
    image = img.copyRectify(
      image,
      topLeft: srcTopLeft,
      topRight: srcTopRight,
      bottomLeft: srcBottomLeft,
      bottomRight: srcBottomRight,
    );

    return await _saveProcessedImage(image, 'perspective');
  }

  /// İşlenmiş resmi kaydeder
  static Future<String> _saveProcessedImage(img.Image image, String filterName) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${filterName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';

    final bytes = img.encodeJpg(image, quality: AppConstants.jpegQuality);
    await File(savedPath).writeAsBytes(bytes);

    return savedPath;
  }
}
