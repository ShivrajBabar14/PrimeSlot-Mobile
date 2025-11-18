import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meetingcalender.dart';

class ScanQR extends StatefulWidget {
  final String token;
  const ScanQR({super.key, required this.token});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  bool _isProcessing = false;
  String? _scannedData;
  String? _myMemberId;

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
    _fetchMyMemberId();
  }

  Future<void> _fetchMyMemberId() async {
    try {
      final response = await http.get(
        Uri.parse('https://prime-slotnew.vercel.app/api/me'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          String photoURL = data['member']['userProfile']['photoURL'] ?? '';
          if (photoURL.isNotEmpty) {
            RegExp regExp = RegExp(r'/profiles/([^/]+)/');
            Match? match = regExp.firstMatch(photoURL);
            if (match != null && match.groupCount >= 1) {
              setState(() {
                _myMemberId = match.group(1)!;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching member ID: $e');
    }
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

    // Log the scanned data to console
    print('QR Code Scanned - Data: $value');

    setState(() {
      _scannedData = value;
      _isProcessing = true;
    });

    // Show the scanned data instead of immediately closing
    _showScannedDataDialog(value);
  }

  void _showScannedDataDialog(String data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Scanned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Member ID:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                data,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  _isProcessing = false;
                  _scannedData = null;
                });
              },
              child: const Text('Scan Again'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get navigator before closing dialog
                final navigator = Navigator.of(context);

                // Close dialog first
                navigator.pop();

                // Call the availability API after dialog is closed
                List<Map<String, DateTime>> busySlots = [];
                if (_myMemberId != null) {
                  try {
                    final response = await http.post(
                      Uri.parse('https://prime-slotnew.vercel.app/api/members/availability'),
                      headers: {
                        'Authorization': 'Bearer ${widget.token}',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode({
                        'aid': _myMemberId,
                        'bid': data,
                      }),
                    );

                    print('Availability API Response: ${response.body}');

                    // Parse busy slots from response
                    if (response.statusCode == 200) {
                      final responseData = jsonDecode(response.body);
                      final busyList = responseData['busy'] as List? ?? [];
                      busySlots = busyList.map((busy) {
                        int startTimestamp = busy['start'];
                        int endTimestamp = busy['end'];

                        // Detect if timestamp is in seconds or milliseconds
                        // Timestamps before 1e10 are likely in seconds, others in milliseconds
                        if (startTimestamp < 10000000000) {
                          startTimestamp *= 1000; // Convert seconds to milliseconds
                        }
                        if (endTimestamp < 10000000000) {
                          endTimestamp *= 1000; // Convert seconds to milliseconds
                        }

                        return {
                          'start': DateTime.fromMillisecondsSinceEpoch(startTimestamp),
                          'end': DateTime.fromMillisecondsSinceEpoch(endTimestamp),
                        };
                      }).toList();
                    }

                    // Navigate to MeetingCalendar after API call
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => MeetingCalendar(
                          scannedUserData: data,
                          busySlots: busySlots,
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Error calling availability API: $e');
                    // Still navigate even if API fails
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => MeetingCalendar(
                          scannedUserData: data,
                          busySlots: busySlots,
                        ),
                      ),
                    );
                  }
                } else {
                  // Navigate even if member ID is not available
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => MeetingCalendar(
                        scannedUserData: data,
                        busySlots: busySlots,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Schedule Meeting'),
            ),
          ],
        );
      },
    );
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
