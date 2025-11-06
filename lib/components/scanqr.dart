import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  bool _isProcessing = false;

  static const double _boxSize = 220.0;
  static const double _borderRadius = 20.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;

    final String? value = codes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _isProcessing = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🔹 Background Camera
            Positioned.fill(
              child: MobileScanner(
                fit: BoxFit.cover,
                onDetect: _onDetect,
              ),
            ),

            /// 🔹 Dim Overlay with Hole
            Positioned.fill(
              child: CustomPaint(
                painter: _HolePainter(
                  boxSize: _boxSize,
                  borderRadius: _borderRadius,
                ),
              ),
            ),

            /// 🔹 Border around scanning area
            Center(
              child: Container(
                width: _boxSize,
                height: _boxSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(_borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            /// 🔹 Animated Scan Line
            Center(
              child: SizedBox(
                width: _boxSize,
                height: _boxSize,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    final double travel = _boxSize - 24;
                    final double y = 12 + travel * _anim.value;

                    return Stack(
                      children: [
                        Positioned(
                          top: y,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.lightBlueAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            /// 🔹 "Scan QR Code" text clearly below the box
            Positioned(
              top: MediaQuery.of(context).size.height / 2 + _boxSize / 2 + 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Align the QR code inside the square to scan automatically",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 Back Button
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            /// 🔹 Top Title
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "QR Scanner",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔸 Painter for transparent hole
class _HolePainter extends CustomPainter {
  final double boxSize;
  final double borderRadius;

  _HolePainter({required this.boxSize, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final fullRect = Offset.zero & size;
    final fullPath = Path()..addRect(fullRect);

    final center = fullRect.center;
    final holeRect = Rect.fromCenter(
      center: center,
      width: boxSize,
      height: boxSize,
    );
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)));

    canvas.saveLayer(fullRect, Paint());
    canvas.drawPath(fullPath, paint);
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawPath(holePath, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HolePainter oldDelegate) {
    return oldDelegate.boxSize != boxSize ||
        oldDelegate.borderRadius != borderRadius;
  }
}
