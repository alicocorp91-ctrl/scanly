import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:scanly/features/editor/presentation/filter_preview.dart';
import 'package:scanly/features/editor/widgets/crop_overlay.dart';
import 'package:scanly/core/utils/image_utils.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/providers/document_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageEditorScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final bool isMultiPage;
  final List<String>? existingPages;

  const ImageEditorScreen({
    super.key,
    required this.imagePath,
    this.isMultiPage = false,
    this.existingPages,
  });

  @override
  ConsumerState<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends ConsumerState<ImageEditorScreen> {
  late String _currentImagePath;
  String _selectedFilter = 'Original';
  bool _isProcessing = false;
  List<String> _pages = [];

  // For multi-page support
  final List<String> _processedPages = [];

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    if (widget.existingPages != null) {
      _pages = List.from(widget.existingPages!);
    }
  }

  Future<void> _applyFilter(String filter) async {
    setState(() {
      _selectedFilter = filter;
      _isProcessing = true;
    });

    // Simulate filter processing (in real implementation use image package)
    await Future.delayed(const Duration(milliseconds: 350));

    // Here we would actually apply filter using image package
    // For now we just update the UI state

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isProcessing = true);

    try {
      // Compress and save the processed image
      final savedPath = await ImageUtils.compressAndSaveImage(_currentImagePath);

      if (widget.isMultiPage) {
        _processedPages.add(savedPath);
        
        // Go back to camera to add more pages
        if (mounted) {
          Navigator.pop(context);
          // Return the new page to parent
          Navigator.pop(context, savedPath);
        }
      } else {
        // Single page - create document
        final documentName = 'Belge_${DateTime.now().toString().substring(0, 16).replaceAll(':', '-')}';
        
        final document = Document.create(
          name: documentName,
          imagePaths: [savedPath],
          thumbnailPath: await ImageUtils.createThumbnail(savedPath),
        );

        await ref.read(documentsProvider.notifier).addDocument(document);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Belge başarıyla kaydedildi'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydetme hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _retakePhoto() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Düzenle', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveAndContinue,
            child: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview Area
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // Main Image
                Center(
                  child: Image.file(
                    File(_currentImagePath),
                    fit: BoxFit.contain,
                  ),
                ),

                // Interactive Crop Overlay
                const CropOverlay(),

                // Processing Overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // Filter Selection
          Container(
            height: 130,
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Filtreler',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('Original', Icons.image),
                      _buildFilterChip('Magic Color', Icons.auto_awesome),
                      _buildFilterChip('B&W', Icons.contrast),
                      _buildFilterChip('Grayscale', Icons.filter_b_and_w),
                      _buildFilterChip('Lightning', Icons.wb_sunny),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retakePhoto,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Yeniden Çek', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _saveAndContinue,
                    icon: const Icon(Icons.check),
                    label: Text(widget.isMultiPage ? 'Sayfa Ekle' : 'Bitir ve Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _applyFilter(label),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.white10,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}