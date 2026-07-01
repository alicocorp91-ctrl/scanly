class AppConstants {
  // App Info
  static const String appName = 'Scanly';
  static const String appVersion = '1.0.0';

  // Database
  static const String documentsBoxName = 'documents';
  static const String foldersBoxName = 'folders';

  // Default Folder Names
  static const String uncategorizedFolderName = 'Uncategorized';

  // Image Quality
  static const int maxImageWidth = 2000;
  static const int jpegQuality = 92;

  // PDF Settings
  static const double a4Width = 595.28;   // points
  static const double a4Height = 841.89;  // points
  static const double letterWidth = 612.0;
  static const double letterHeight = 792.0;

  // OCR
  static const String ocrLanguage = 'tr'; // Turkish + English supported by ML Kit

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
}