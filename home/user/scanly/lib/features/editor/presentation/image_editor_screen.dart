import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:scanly/features/editor/widgets/interactive_cropper.dart';
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
  bool _showCropper = false;

  final List<String> _processedPages = [];

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  void _openCropper() {
    setState(() {
      _showCropper = true;
    });
  }

  void _closeCropper() {
    setState(() {
      _showCropper = false;
    });
  }

  Future<void> _applyCrop(List<Offset> normalizedCorners) async {
    setState(() => _isProcessing = true);

    try {
      // Perspektif düzeltme + kırpma
      final correctedPath = await ImageUtils.applyPerspectiveCorrection(
        _currentImagePath,
        normalizedCorners,
      );

      _currentImagePath = correctedPath;

      if (widget.isMultiPage) {
        _processedPages.add(_currentImagePath);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, _currentImagePath);
        }
      } else {
        final documentName = 'Belge_${DateTime.now().toString().substring(0, 16).replaceAll(':', '-')}';
        
        final document = Document.create(
          name: documentName,
          imagePaths: [_currentImagePath],
          thumbnailPath: await ImageUtils.createThumbnail(_currentImagePath),
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
          SnackBar(content: Text('İşlem hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _showCropper = false;
        });
      }
    }
  }

  Future<void> _applyFilter(String filter) async {
    setState(() {
      _selectedFilter = filter;
      _isProcessing = true;
    });

    try {
      String newPath;

      switch (filter) {
        case 'Magic Color':
          newPath = await ImageUtils.applyMagicColor(_currentImagePath);
          break;
        case 'B&W':
          newPath = await ImageUtils.applyBlackAndWhite(_currentImagePath);
          break;
        case 'Grayscale':
          newPath = await ImageUtils.applyGrayscale(_currentImagePath);
          break;
        case 'Lightning':
          newPath = await ImageUtils.applyLightning(_currentImagePath);
          break;
        default:
          newPath = await ImageUtils.applyOriginal(_currentImagePath);
      }

      setState(() {
        _currentImagePath = newPath;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filtre uygulanamadı: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveWithoutCrop() async {
    setState(() => _isProcessing = true);

    try {
      final savedPath = await ImageUtils.compressAndSaveImage(_currentImagePath);

      if (widget.isMultiPage) {
        _processedPages.add(savedPath);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, savedPath);
        }
      } else {
        final documentName = 'Belge_${DateTime.now().toString().substring(0, 16).replaceAll(':', '-')}';
        
        final document = Document.create(
          name: documentName,
          imagePaths: [savedPath],
          thumbnailPath: await ImageUtils.createThumbnail(savedPath),
        );

        await ref.read(documentsProvider.notifier).addDocument(document);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belge kaydedildi')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
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
    if (_showCropper) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: InteractiveCropper(
          imagePath: _currentImagePath,
          onCropComplete: _applyCrop,
          onCancel: _closeCropper,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Düzenle', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveWithoutCrop,
            child: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Görsel Önizleme
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Center(
                  child: Image.file(
                    File(_currentImagePath),
                    fit: BoxFit.contain,
                  ),
                ),
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

          // Filtreler
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
                      Text('Filtreler', style: TextStyle(color: Colors.white70, fontSize: 14)),
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

          // Alt Butonlar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: Column(
              children: [
                Row(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _openCropper,
                        icon: const Icon(Icons.crop),
                        label: const Text('Kırp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _saveWithoutCrop,
                    icon: const Icon(Icons.check),
                    label: Text(widget.isMultiPage ? 'Sayfa Ekle' : 'Bitir ve Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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