import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/bottmnav.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  bool _isVerifying = false;

  void _verifyOtp() {
    String otp = _otpControllers.map((e) => e.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid 4-digit OTP",
              style: GoogleFonts.montserrat(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Simulate verification delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP Verified Successfully!",
              style: GoogleFonts.montserrat(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to BottomNav with dashboard selected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNav()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF9FBFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, size: 80, color: Color(0xFF0052CC)),
              const SizedBox(height: 20),

              Text(
                'OTP Verification',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the OTP sent to +91 ${widget.mobileNumber}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBFD8FF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0052CC),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              // 🔹 Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Verify OTP',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Resend Text
              TextButton(
                onPressed: () {},
                child: Text(
                  "Resend OTP",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF0052CC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
