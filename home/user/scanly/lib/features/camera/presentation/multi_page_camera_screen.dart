import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanly/core/services/permission_service.dart';
import 'package:scanly/features/editor/presentation/image_editor_screen.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/providers/document_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class MultiPageCameraScreen extends ConsumerStatefulWidget {
  const MultiPageCameraScreen({super.key});

  @override
  ConsumerState<MultiPageCameraScreen> createState() => _MultiPageCameraScreenState();
}

class _MultiPageCameraScreenState extends ConsumerState<MultiPageCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  List<String> _capturedPages = [];
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final hasPermission = await PermissionService.requestCameraPermission(context);
    if (!hasPermission) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _cameras = await availableCameras();
    if (_cameras!.isEmpty) return;

    _controller = CameraController(_cameras![0], ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();

    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();

    // Go to editor for this page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(
          imagePath: file.path,
          isMultiPage: true,
        ),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _capturedPages.add(result);
      });
    }
  }

  Future<void> _addFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageEditorScreen(
            imagePath: image.path,
            isMultiPage: true,
          ),
        ),
      );

      if (result != null && result is String) {
        setState(() {
          _capturedPages.add(result);
        });
      }
    }
  }

  Future<void> _finishDocument() async {
    if (_capturedPages.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final name = 'Belge_${DateTime.now().toString().substring(0, 16).replaceAll(':', '-')}';

    final document = Document.create(
      name: name,
      imagePaths: _capturedPages,
      thumbnailPath: await _createThumbnail(_capturedPages.first),
    );

    await ref.read(documentsProvider.notifier).addDocument(document);

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çok sayfalı belge kaydedildi')),
      );
    }
  }

  Future<String?> _createThumbnail(String path) async {
    // Simple thumbnail creation
    try {
      final file = File(path);
      return file.path; // For simplicity, use original path
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_capturedPages.length} sayfa', style: const TextStyle(color: Colors.white)),
        actions: [
          if (_capturedPages.isNotEmpty)
            TextButton(
              onPressed: _finishDocument,
              child: const Text('Bitir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized && _controller != null)
            CameraPreview(_controller!),
          
          // Page thumbnails strip
          if (_capturedPages.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _capturedPages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(_capturedPages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Capture controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'gallery_multi',
                  onPressed: _addFromGallery,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.photo_library, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'finish_multi',
                  onPressed: _capturedPages.isNotEmpty ? _finishDocument : null,
                  backgroundColor: _capturedPages.isNotEmpty ? AppColors.accent : Colors.grey,
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}