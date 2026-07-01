import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showPermissionDialog(context, 'Kamera İzni Gerekli', 
        'Belge taramak için kamera iznine ihtiyacımız var.');
      return false;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, 'Kamera İzni Reddedildi');
      return false;
    }
    return false;
  }

  static Future<bool> requestStoragePermission(BuildContext context) async {
    final status = await Permission.storage.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, 'Depolama İzni Reddedildi');
      return false;
    }
    return false;
  }

  static void _showPermissionDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }

  static void _showSettingsDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Bu özelliği kullanmak için ayarlardan izin vermeniz gerekiyor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }
}