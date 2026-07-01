import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:scanly/core/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scanly/features/ocr/presentation/ocr_screen.dart';
import 'package:scanly/features/documents/presentation/page_reorder_screen.dart';
import 'package:scanly/core/providers/document_provider.dart';
import 'package:flutter/services.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late Document _document;
  String _selectedPageSize = 'A4';
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
  }

  Future<void> _shareAsPdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdfFile = await PdfService.generatePdf(
        document: _document,
        pageSize: _selectedPageSize,
      );

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: '${_document.name} - Scanly',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF oluşturulamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _shareAsImage() async {
    if (_document.imagePaths.isEmpty) return;

    await Share.shareXFiles(
      _document.imagePaths.map((path) => XFile(path)).toList(),
      text: _document.name,
    );
  }

  void _openOcr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OcrScreen(document: _document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_document.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: _openOcr,
            tooltip: 'Metin Tanıma (OCR)',
          ),
          IconButton(
            icon: const Icon(Icons.reorder_rounded),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PageReorderScreen(document: _document),
                ),
              );
              if (updated == true) {
                // Refresh document from provider
                final docs = ref.read(documentsProvider);
                final refreshed = docs.firstWhere((d) => d.id == _document.id);
                setState(() => _document = refreshed);
              }
            },
            tooltip: 'Sayfa Sırala',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'pdf') _shareAsPdf();
              if (value == 'image') _shareAsImage();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pdf', child: Text('PDF Olarak Paylaş')),
              const PopupMenuItem(value: 'image', child: Text('Resim Olarak Paylaş')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Page Size Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Sayfa Boyutu: ', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('A4'),
                  selected: _selectedPageSize == 'A4',
                  onSelected: (_) => setState(() => _selectedPageSize = 'A4'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Letter'),
                  selected: _selectedPageSize == 'Letter',
                  onSelected: (_) => setState(() => _selectedPageSize = 'Letter'),
                ),
              ],
            ),
          ),

          // Pages Preview
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _document.imagePaths.length,
              itemBuilder: (context, index) {
                final path = _document.imagePaths[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(
                            image: FileImage(File(path)),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text('Sayfa ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                Share.shareXFiles([XFile(path)]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGeneratingPdf ? null : _shareAsPdf,
        icon: _isGeneratingPdf
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf),
        label: Text(_isGeneratingPdf ? 'Oluşturuluyor...' : 'PDF Paylaş'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}