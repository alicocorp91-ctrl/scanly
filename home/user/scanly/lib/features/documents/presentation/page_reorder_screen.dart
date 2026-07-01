import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/providers/document_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanly/core/theme/app_colors.dart';

class PageReorderScreen extends ConsumerStatefulWidget {
  final Document document;

  const PageReorderScreen({super.key, required this.document});

  @override
  ConsumerState<PageReorderScreen> createState() => _PageReorderScreenState();
}

class _PageReorderScreenState extends ConsumerState<PageReorderScreen> {
  late List<String> _pages;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.document.imagePaths);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, item);
    });
  }

  Future<void> _saveReorderedPages() async {
    setState(() => _isSaving = true);

    try {
      final updatedDoc = widget.document.copyWith(
        imagePaths: _pages,
        pageCount: _pages.length,
        thumbnailPath: _pages.isNotEmpty ? _pages.first : null,
      );

      await ref.read(documentsProvider.notifier).updateDocument(updatedDoc);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sayfa sırası güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sayfa Sıralaması'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveReorderedPages,
            child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pages.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final path = _pages[index];
          return Card(
            key: ValueKey(path),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(path),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text('Sayfa ${index + 1}'),
              trailing: const Icon(Icons.drag_handle_rounded),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveReorderedPages,
            icon: const Icon(Icons.save),
            label: const Text('Sıralamayı Kaydet'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ),
      ),
    );
  }
}