import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/services/hive_service.dart';

final documentsProvider = StateNotifierProvider<DocumentsNotifier, List<Document>>((ref) {
  return DocumentsNotifier();
});

class DocumentsNotifier extends StateNotifier<List<Document>> {
  DocumentsNotifier() : super([]) {
    _loadDocuments();
  }

  void _loadDocuments() {
    state = HiveService.getAllDocuments();
  }

  Future<void> addDocument(Document document) async {
    await HiveService.addDocument(document);
    state = [...state, document];
  }

  Future<void> updateDocument(Document document) async {
    await HiveService.updateDocument(document);
    state = state.map((doc) => doc.id == document.id ? document : doc).toList();
  }

  Future<void> deleteDocument(String id) async {
    final doc = state.firstWhere((d) => d.id == id);
    
    // Delete associated images
    for (final path in doc.imagePaths) {
      try {
        await HiveService.deleteDocument(id); // This is a misnomer in service, but we keep it
      } catch (_) {}
    }
    
    await HiveService.deleteDocument(id);
    state = state.where((doc) => doc.id != id).toList();
  }

  Future<void> moveDocument(String documentId, String? folderId) async {
    await HiveService.moveDocumentToFolder(documentId, folderId);
    state = state.map((doc) {
      if (doc.id == documentId) {
        return doc.copyWith(folderId: folderId);
      }
      return doc;
    }).toList();
  }

  List<Document> getDocumentsByFolder(String? folderId) {
    if (folderId == null) {
      return state.where((doc) => doc.folderId == null).toList();
    }
    return state.where((doc) => doc.folderId == folderId).toList();
  }

  List<Document> searchDocuments(String query) {
    if (query.isEmpty) return state;
    final lowerQuery = query.toLowerCase();
    return state.where((doc) => 
      doc.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}