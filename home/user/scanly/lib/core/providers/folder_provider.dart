import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanly/shared/models/folder_model.dart';
import 'package:scanly/core/services/hive_service.dart';

final foldersProvider = StateNotifierProvider<FoldersNotifier, List<Folder>>((ref) {
  return FoldersNotifier();
});

class FoldersNotifier extends StateNotifier<List<Folder>> {
  FoldersNotifier() : super([]) {
    _loadFolders();
  }

  void _loadFolders() {
    state = HiveService.getAllFolders();
  }

  Future<void> addFolder(Folder folder) async {
    await HiveService.addFolder(folder);
    state = [...state, folder];
  }

  Future<void> updateFolder(Folder folder) async {
    await HiveService.updateFolder(folder);
    state = state.map((f) => f.id == folder.id ? folder : f).toList();
  }

  Future<void> deleteFolder(String id) async {
    await HiveService.deleteFolder(id);
    state = state.where((folder) => folder.id != id).toList();
  }

  Folder? getFolderById(String id) {
    try {
      return state.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}