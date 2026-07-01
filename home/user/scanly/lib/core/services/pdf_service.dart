import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:scanly/core/constants/app_constants.dart';
import 'package:scanly/shared/models/document_model.dart';

class PdfService {
  static Future<File> generatePdf({
    required Document document,
    required String pageSize,
    List<String>? imagePaths,
  }) async {
    final pdf = pw.Document();

    final paths = imagePaths ?? document.imagePaths;

    // Determine page dimensions
    late PdfPageFormat pageFormat;
    if (pageSize == 'A4') {
      pageFormat = PdfPageFormat.a4;
    } else if (pageSize == 'Letter') {
      pageFormat = PdfPageFormat.letter;
    } else {
      pageFormat = PdfPageFormat.a4;
    }

    for (final imagePath in paths) {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pdfImage,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    // Save PDF
    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = '${document.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<File> generateMultiPagePdf({
    required String documentName,
    required List<String> imagePaths,
    String pageSize = 'A4',
  }) async {
    final pdf = pw.Document();

    late PdfPageFormat pageFormat;
    if (pageSize == 'A4') {
      pageFormat = PdfPageFormat.a4;
    } else {
      pageFormat = PdfPageFormat.letter;
    }

    for (final path in imagePaths) {
      final imageFile = File(path);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = '${documentName.replaceAll(' ', '_')}.pdf';
    final file = File('${outputDir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}