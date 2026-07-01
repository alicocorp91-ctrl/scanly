import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class OcrScreen extends StatefulWidget {
  final Document document;

  const OcrScreen({super.key, required this.document});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  String _recognizedText = '';
  bool _isProcessing = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _performOcr();
  }

  Future<void> _performOcr() async {
    if (widget.document.imagePaths.isEmpty) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Belgede görüntü bulunamadı.';
      });
      return;
    }

    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final inputImage = InputImage.fromFilePath(widget.document.imagePaths.first);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _recognizedText = recognizedText.text;
        _isProcessing = false;
      });

      await textRecognizer.close();
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Metin tanınamadı: $e';
      });
    }
  }

  void _copyToClipboard() {
    if (_recognizedText.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Metin panoya kopyalandı')),
    );
  }

  Future<void> _shareAsText() async {
    if (_recognizedText.isEmpty) return;

    final fileName = '${widget.document.name}_metin.txt';
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(_recognizedText);

    await Share.shareXFiles([XFile(file.path)], text: widget.document.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metin Tanıma (OCR)'),
        actions: [
          if (_recognizedText.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Kopyala',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareAsText,
              tooltip: 'Metni Paylaş',
            ),
          ],
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text('Metin tanınıyor...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(_errorMessage, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _performOcr,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : _recognizedText.isEmpty
                  ? const Center(
                      child: Text(
                        'Belgede metin bulunamadı.',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _recognizedText,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),
                    ),
      floatingActionButton: _recognizedText.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Kopyala'),
            )
          : null,
    );
  }
}