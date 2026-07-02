import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanly/core/providers/document_provider.dart';
import 'package:scanly/core/providers/folder_provider.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/shared/models/folder_model.dart';
import 'package:scanly/shared/widgets/empty_state.dart';
import 'package:scanly/shared/widgets/folder_card.dart';
import 'package:scanly/shared/widgets/document_card.dart';
import 'package:scanly/features/documents/presentation/document_detail_screen.dart';
import 'package:scanly/features/camera/presentation/camera_screen.dart';
import 'package:scanly/features/camera/presentation/multi_page_camera_screen.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:scanly/features/settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isGridView = true;
  String _searchQuery = '';
  String? _selectedFolderId;

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider);
    final folders = ref.watch(foldersProvider);

    final filteredDocuments = _searchQuery.isEmpty
        ? (_selectedFolderId == null
            ? documents.where((d) => d.folderId == null).toList()
            : documents.where((d) => d.folderId == _selectedFolderId).toList())
        : documents.where((doc) => 
            doc.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final currentFolderDocs = _selectedFolderId == null
        ? documents.where((d) => d.folderId == null).toList()
        : documents.where((d) => d.folderId == _selectedFolderId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanly'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Belge ara...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Folders Section
          if (folders.isNotEmpty || _selectedFolderId != null)
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // All / Root button
                  _buildFolderChip(
                    label: 'Tümü',
                    isSelected: _selectedFolderId == null,
                    onTap: () => setState(() => _selectedFolderId = null),
                  ),
                  const SizedBox(width: 12),
                  ...folders.map((folder) {
                    final docCount = documents.where((d) => d.folderId == folder.id).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FolderCard(
                        folder: folder,
                        documentCount: docCount,
                        onTap: () {
                          setState(() => _selectedFolderId = folder.id);
                        },
                        onEdit: () => _showEditFolderDialog(folder),
                        onDelete: () => _deleteFolder(folder),
                      ),
                    );
                  }),
                  // Add Folder Button
                  _buildAddFolderButton(),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Documents Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _selectedFolderId == null 
                      ? 'Belgelerim' 
                      : (folders.firstWhere((f) => f.id == _selectedFolderId).name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredDocuments.length} belge',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Documents List/Grid
          Expanded(
            child: filteredDocuments.isEmpty
                ? EmptyState(
                    title: _searchQuery.isNotEmpty 
                        ? 'Sonuç bulunamadı' 
                        : 'Henüz belge yok',
                    subtitle: _searchQuery.isNotEmpty 
                        ? 'Aramanıza uygun belge bulunamadı' 
                        : 'İlk belgenizi taramak için alttaki butona dokunun',
                    icon: Icons.folder_open_rounded,
                    onAction: _searchQuery.isEmpty ? _startNewScan : null,
                    actionText: 'Belge Tara',
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocuments[index];
                          return DocumentCard(
                            document: doc,
                            onTap: () => _openDocument(doc),
                            onLongPress: () => _showDocumentOptions(doc),
                            onDelete: () => _deleteDocument(doc),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocuments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.description_rounded, size: 40),
                              title: Text(doc.name),
                              subtitle: Text('${doc.pageCount} sayfa • ${doc.updatedAt.toLocal().toString().split(' ')[0]}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showDocumentOptions(doc),
                              ),
                              onTap: () => _openDocument(doc),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Tek Sayfa Tara'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_enhance),
                    title: const Text('Çok Sayfa Tara'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MultiPageCameraScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Tara'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFolderChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFolderButton() {
    return GestureDetector(
      onTap: _showCreateFolderDialog,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textTertiary.withOpacity(0.2)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create_new_folder_rounded, size: 32, color: AppColors.primary),
            SizedBox(height: 8),
            Text(
              'Yeni Klasör',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startNewScan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  void _openDocument(Document document) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentDetailScreen(document: document),
      ),
    );
  }

  void _showDocumentOptions(Document document) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Yeniden Adlandır'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Klasöre Taşı'),
              onTap: () {
                Navigator.pop(context);
                _showMoveToFolderDialog(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteDocument(document);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Klasör Oluştur'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Klasör adı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final folder = Folder.create(name: result);
      await ref.read(foldersProvider.notifier).addFolder(folder);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result} klasörü oluşturuldu')),
        );
      }
    }
  }

  Future<void> _showEditFolderDialog(Folder folder) async {
    final controller = TextEditingController(text: folder.name);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klasörü Düzenle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Klasör adı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != folder.name) {
      final updated = folder.copyWith(name: result);
      await ref.read(foldersProvider.notifier).updateFolder(updated);
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klasörü Sil?'),
        content: const Text('Bu klasördeki belgeler "Tümü" bölümüne taşınacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Move documents out of folder
      final docs = ref.read(documentsProvider);
      for (final doc in docs) {
        if (doc.folderId == folder.id) {
          await ref.read(documentsProvider.notifier).moveDocument(doc.id, null);
        }
      }
      
      await ref.read(foldersProvider.notifier).deleteFolder(folder.id);
      
      if (mounted) {
        setState(() => _selectedFolderId = null);
      }
    }
  }

  Future<void> _showRenameDialog(Document document) async {
    final controller = TextEditingController(text: document.name);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belgeyi Yeniden Adlandır'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final updated = document.copyWith(name: result);
      await ref.read(documentsProvider.notifier).updateDocument(updated);
    }
  }

  Future<void> _showMoveToFolderDialog(Document document) async {
    final folders = ref.read(foldersProvider);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klasöre Taşı'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Tümü (Klasörsüz)'),
                onTap: () {
                  ref.read(documentsProvider.notifier).moveDocument(document.id, null);
                  Navigator.pop(context);
                },
              ),
              ...folders.map((folder) => ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                onTap: () {
                  ref.read(documentsProvider.notifier).moveDocument(document.id, folder.id);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDocument(Document document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belgeyi Sil?'),
        content: Text('${document.name} silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(documentsProvider.notifier).deleteDocument(document.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belge silindi')),
        );
      }
    }
  }
}