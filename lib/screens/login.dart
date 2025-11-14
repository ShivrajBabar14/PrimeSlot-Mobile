import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
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

  // Use your widgetId and tokenAuth from MSG91 dashboard (same as web)
  static const String _widgetId = '356b67656c53363533323930';
  static const String _tokenAuth = '417046TmuGjcKYAXo6915aa30P1';

  @override
  void initState() {
    super.initState();
    // Initialize MSG91 OTP Widget for mobile SDK
    try {
      OTPWidget.initializeWidget(_widgetId, _tokenAuth);
      print('MSG91 widget initialized.');
    } catch (e) {
      print('Failed to init MSG91 widget: $e');
    }
  }

  Future<void> _getOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final phoneNumberOnly = _mobileController.text.trim();
    final fullPhone = '91' + phoneNumberOnly; // ensure with country code

    final checkUserUrl = Uri.parse(
      'https://prime-slotnew.vercel.app/api/check-user',
    );

    try {
      final checkUserResponse = await http.post(
        checkUserUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': fullPhone}),
      );

      print(
        'Check User API: ${checkUserResponse.statusCode} ${checkUserResponse.body}',
      );

      if (checkUserResponse.statusCode == 200) {
        final responseData = jsonDecode(checkUserResponse.body);
        if (responseData['ok'] == true && responseData['exists'] == true) {
          // MEMBER EXISTS — now use the mobile SDK to send OTP (so same widget config as web)
          try {
            final sendData = {'identifier': fullPhone};
            final sdkResp = await OTPWidget.sendOTP(sendData);
            print('SDK sendOTP response: $sdkResp');
            // Extract request id robustly
            final reqId =
                sdkResp?['reqId'] ??
                sdkResp?['request_id'] ??
                sdkResp?['requestId'] ??
                sdkResp?['req_id'] ??
                sdkResp?['txnId'] ??
                sdkResp?['data']?['reqId'] ??
                sdkResp?['data']?['request_id'] ??
                sdkResp?['message'];
            final isDemo =
                (sdkResp?['isDemo'] == true) ||
                (sdkResp?['demo'] == true) ||
                (sdkResp?['demo_pin'] != null) ||
                (sdkResp?['otp_pin'] != null);
            if (reqId == null) {
              // If no reqId at all, print sdkResp and notify user — do not continue to verify without reqId
              print(
                'WARNING: sendOTP returned no reqId. Full sdkResp: $sdkResp',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP send returned no request id. Check logs.'),
                ),
              );
              setState(() => _isLoading = false);
              return;
            }
            // Navigate to OTP screen and pass reqId and phone
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  mobileNumber: phoneNumberOnly,
                  reqId: reqId,
                  isDemo: isDemo,
                ),
              ),
            );
          } catch (e) {
            print('SDK sendOTP error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to send OTP via SDK: $e')),
            );
            setState(() => _isLoading = false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone not registered. Please sign up.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error checking user: ${checkUserResponse.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
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
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Color(0xFF0052CC),
              ),
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
                    prefixIcon: const Icon(
                      Icons.phone_android_outlined,
                      color: Color(0xFF0052CC),
                    ),
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
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your mobile number';
                    if (value.length != 10)
                      return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
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
