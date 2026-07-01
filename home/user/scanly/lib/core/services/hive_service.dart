import 'package:hive_flutter/hive_flutter.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/shared/models/folder_model.dart';

class HiveService {
  static const String foldersBox = 'folders';
  static const String documentsBox = 'documents';

  static Box<Folder> get foldersBoxInstance => Hive.box<Folder>(foldersBox);
  static Box<Document> get documentsBoxInstance => Hive.box<Document>(documentsBox);

  // Folder Operations
  static Future<void> addFolder(Folder folder) async {
    await foldersBoxInstance.put(folder.id, folder);
  }

  static Future<void> updateFolder(Folder folder) async {
    await foldersBoxInstance.put(folder.id, folder);
  }

  static Future<void> deleteFolder(String id) async {
    await foldersBoxInstance.delete(id);
  }

  static List<Folder> getAllFolders() {
    return foldersBoxInstance.values.toList();
  }

  // Document Operations
  static Future<void> addDocument(Document document) async {
    await documentsBoxInstance.put(document.id, document);
  }

  static Future<void> updateDocument(Document document) async {
    await documentsBoxInstance.put(document.id, document);
  }

  static Future<void> deleteDocument(String id) async {
    await documentsBoxInstance.delete(id);
  }

  static List<Document> getAllDocuments() {
    return documentsBoxInstance.values.toList();
  }

  static List<Document> getDocumentsByFolder(String? folderId) {
    if (folderId == null) {
      return documentsBoxInstance.values
          .where((doc) => doc.folderId == null)
          .toList();
    }
    return documentsBoxInstance.values
        .where((doc) => doc.folderId == folderId)
        .toList();
  }

  static Future<void> moveDocumentToFolder(String documentId, String? folderId) async {
    final doc = documentsBoxInstance.get(documentId);
    if (doc != null) {
      final updatedDoc = doc.copyWith(folderId: folderId);
      await documentsBoxInstance.put(documentId, updatedDoc);
    }
  }
}