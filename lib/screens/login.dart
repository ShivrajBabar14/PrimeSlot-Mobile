import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _getOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String phone = '91' + _mobileController.text;
      final checkUserUrl = Uri.parse('https://prime-slotnew.vercel.app/api/check-user');
      final body = jsonEncode({'phone': phone});

      try {
        final checkUserResponse = await http.post(
          checkUserUrl,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        print('Check User API Response: ${checkUserResponse.statusCode} - ${checkUserResponse.body}');

        if (checkUserResponse.statusCode == 200) {
          final responseData = jsonDecode(checkUserResponse.body);
          if (responseData['ok'] == true && responseData['exists'] == true) {
            // User verified, now send OTP
            final sendOtpUrl = Uri.parse('https://prime-slotnew.vercel.app/api/send-otp');
            final otpResponse = await http.post(
              sendOtpUrl,
              headers: {'Content-Type': 'application/json'},
              body: body,
            );

            print('Send OTP API Response: ${otpResponse.statusCode} - ${otpResponse.body}');

            if (otpResponse.statusCode == 200) {
              // Success, navigate to OTP screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpScreen(mobileNumber: _mobileController.text),
                ),
              );
            } else {
              // Handle send OTP error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to send OTP: ${otpResponse.statusCode}')),
              );
            }
          } else {
            // User not verified
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not verified or does not exist')),
            );
          }
        } else {
          // Handle check user error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking user: ${checkUserResponse.statusCode}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Color(0xFF0052CC)),
              const SizedBox(height: 20),

              Text(
                'Welcome',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Login using your mobile number',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Mobile Number Form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  cursorColor: const Color(0xFF0052CC),
                  style: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: GoogleFonts.montserrat(
                      color: const Color(0xFF0052CC),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(Icons.phone_android_outlined, color: Color(0xFF0052CC)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFD8FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0052CC), width: 1.5),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (value.length != 10) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Get OTP Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Get OTP',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
