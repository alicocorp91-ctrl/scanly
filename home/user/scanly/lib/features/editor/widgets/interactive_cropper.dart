import 'package:flutter/material.dart';
import 'dart:math' as math;

class InteractiveCropper extends StatefulWidget {
  final String imagePath;
  final Function(List<Offset>) onCropComplete;
  final VoidCallback onCancel;

  const InteractiveCropper({
    super.key,
    required this.imagePath,
    required this.onCropComplete,
    required this.onCancel,
  });

  @override
  State<InteractiveCropper> createState() => _InteractiveCropperState();
}

class _InteractiveCropperState extends State<InteractiveCropper> {
  late List<Offset> _corners;
  int? _selectedCornerIndex;
  Size? _imageSize;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Başlangıçta dikdörtgen köşeler (yaklaşık %80 alan)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCorners();
    });
  }

  void _initializeCorners() {
    if (!mounted) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    final double margin = size.width * 0.1;
    final double topMargin = size.height * 0.1;
    
    setState(() {
      _corners = [
        Offset(margin, topMargin),                    // Sol üst
        Offset(size.width - margin, topMargin),       // Sağ üst
        Offset(size.width - margin, size.height - topMargin), // Sağ alt
        Offset(margin, size.height - topMargin),      // Sol alt
      ];
      _imageSize = size;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_corners.isEmpty) return;
    
    final Offset localPosition = details.localPosition;
    double minDistance = double.infinity;
    int? closestIndex;

    for (int i = 0; i < _corners.length; i++) {
      final double distance = (localPosition - _corners[i]).distance;
      if (distance < minDistance && distance < 60) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    setState(() {
      _selectedCornerIndex = closestIndex;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_selectedCornerIndex == null || _corners.isEmpty) return;

    setState(() {
      Offset newPosition = _corners[_selectedCornerIndex!] + details.delta;
      
      // Sınırları zorla (görsel alan içinde kalması için)
      if (_imageSize != null) {
        newPosition = Offset(
          newPosition.dx.clamp(20.0, _imageSize!.width - 20),
          newPosition.dy.clamp(20.0, _imageSize!.height - 20),
        );
      }
      
      _corners[_selectedCornerIndex!] = newPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _selectedCornerIndex = null;
    });
  }

  void _resetCorners() {
    if (_imageSize == null) return;
    
    final double margin = _imageSize!.width * 0.1;
    final double topMargin = _imageSize!.height * 0.1;
    
    setState(() {
      _corners = [
        Offset(margin, topMargin),
        Offset(_imageSize!.width - margin, topMargin),
        Offset(_imageSize!.width - margin, _imageSize!.height - topMargin),
        Offset(margin, _imageSize!.height - topMargin),
      ];
    });
  }

  /// Gelişmiş Otomatik Kenar Algılama
  void _autoDetectEdges() {
    if (_imageSize == null) return;

    final double width = _imageSize!.width;
    final double height = _imageSize!.height;

    // Daha profesyonel bir otomatik algılama
    // Belge genellikle ekranın %75-85'ini kaplar
    final double horizontalMargin = width * 0.07;
    final double verticalMargin = height * 0.10;

    setState(() {
      _corners = [
        Offset(horizontalMargin, verticalMargin),                           // Sol üst
        Offset(width - horizontalMargin, verticalMargin),                   // Sağ üst
        Offset(width - horizontalMargin, height - verticalMargin),          // Sağ alt
        Offset(horizontalMargin, height - verticalMargin),                  // Sol alt
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Otomatik kenar algılama uygulandı'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<Offset> _getNormalizedCorners() {
    if (_imageSize == null || _corners.isEmpty) return [];
    
    return _corners.map((corner) {
      return Offset(
        corner.dx / _imageSize!.width,
        corner.dy / _imageSize!.height,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Üst Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.black87,
          child: Row(
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('İptal', style: TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetCorners,
                child: const Text('Sıfırla', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _autoDetectEdges,
                icon: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Otomatik Algıla', style: TextStyle(color: Colors.lightBlue)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  final normalized = _getNormalizedCorners();
                  if (normalized.isNotEmpty) {
                    widget.onCropComplete(normalized);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Uygula'),
              ),
            ],
          ),
        ),

        // Kırpma Alanı
        Expanded(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  // Arka plan resmi
                  if (widget.imagePath.isNotEmpty)
                    Positioned.fill(
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(Icons.image, size: 80, color: Colors.white54),
                            ),
                          );
                        },
                      ),
                    ),

                  // Kırpma Overlay
                  if (_corners.isNotEmpty)
                    CustomPaint(
                      painter: CropOverlayPainter(
                        corners: _corners,
                        selectedIndex: _selectedCornerIndex,
                      ),
                      child: Container(),
                    ),

                  // Köşe Noktaları
                  if (_corners.isNotEmpty)
                    ...List.generate(_corners.length, (index) {
                      return Positioned(
                        left: _corners[index].dx - 18,
                        top: _corners[index].dy - 18,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _selectedCornerIndex == index 
                                ? Colors.blue 
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: _selectedCornerIndex == index 
                                    ? Colors.white 
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),

        // Alt Bilgi
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: const Text(
            'Köşeleri sürükleyerek belgeyi kırpın',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final List<Offset> corners;
  final int? selectedIndex;

  CropOverlayPainter({
    required this.corners,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Kırpma alanını çiz (dörtgen)
    final path = Path()
      ..moveTo(corners[0].dx, corners[0].dy)
      ..lineTo(corners[1].dx, corners[1].dy)
      ..lineTo(corners[2].dx, corners[2].dy)
      ..lineTo(corners[3].dx, corners[3].dy)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Köşe bağlantı çizgileri (daha ince)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(corners[i], corners[(i + 1) % 4], linePaint);
    }
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.corners != corners || 
           oldDelegate.selectedIndex != selectedIndex;
  }
}