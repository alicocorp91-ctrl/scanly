import 'dart:io';
import 'dart:typed_data';
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
}