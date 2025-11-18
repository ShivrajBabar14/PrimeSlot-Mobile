// otp_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import 'take_profile.dart';
import '../components/bottmnav.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber; // plain 10-digit without country prefix
  final String? reqId;
  final bool isDemo;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    this.reqId,
    this.isDemo = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Use 4 digits for OTP
  static const int OTP_LENGTH = 4;
  late final List<TextEditingController> _otpControllers;
  bool _isVerifying = false;
  String? _reqIdLocal;

  @override
  void initState() {
    super.initState();
    _reqIdLocal = widget.reqId;
    _otpControllers = List.generate(OTP_LENGTH, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _otpControllers) c.dispose();
    super.dispose();
  }

  String collectedOtp() => _otpControllers.map((c) => c.text.trim()).join();

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length != _otpControllers.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter full OTP')));
      return;
    }
    setState(() => _isVerifying = true);
    try {
      // Build verify body and include reqId
      final body = <String, dynamic>{'otp': otp};
      final reqId = widget.reqId ?? _reqIdLocal;
      if (reqId != null && reqId.toString().isNotEmpty) body['reqId'] = reqId;
      // Debug print
      print('Calling SDK verifyOTP with body: $body');
      final sdkResp = await OTPWidget.verifyOTP(body);
      print('SDK verify response: $sdkResp');
      // If SDK returns an error object, show it
      if (sdkResp == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Empty SDK response')));
        setState(() => _isVerifying = false);
        return;
      }
      // Look for access token (if verify returns one)
      final accessToken =
          sdkResp['access-token'] ??
          sdkResp['accessToken'] ??
          sdkResp['access_token'] ??
          sdkResp['token'] ??
          (sdkResp['data'] is Map
              ? sdkResp['data']['access-token'] ?? sdkResp['data']['token']
              : null) ??
          sdkResp['message'];
      // If SDK returns an error (e.g. invalid otp), it often contains type/message
      if (sdkResp['type'] == 'error' ||
          sdkResp['status'] == 'fail' ||
          sdkResp['hasError'] == true) {
        final msg = sdkResp['message'] ?? sdkResp['msg'] ?? 'OTP verify failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        setState(() => _isVerifying = false);
        return;
      }
      if (accessToken == null) {
        // If no access token but SDK says success, you can still proceed to server verify
        // but only if your server accepts that. Print sdkResp for debugging.
        print('No accessToken in SDK verify response. Full: $sdkResp');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No access token returned by SDK. Check logs.'),
          ),
        );
        setState(() => _isVerifying = false);
        return;
      }
      // Send accessToken to server for server-side verification
      final serverUrl = Uri.parse(
        'https://prime-slotnew.vercel.app/api/verify-widget-token',
      );
      final res = await http.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': accessToken,
          'phone': '91${widget.mobileNumber}',
        }),
      );
      final jsonResp = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      print('Server verify response: ${res.statusCode} -> $jsonResp');
      if (res.statusCode == 200 &&
          (jsonResp['success'] == true || jsonResp['ok'] == true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verified — login success')),
        );
        // Extract token from server response
        final serverToken = jsonResp['token'];

        // Call /api/me to check profile approval status
        final meUrl = Uri.parse('https://prime-slotnew.vercel.app/api/me');
        final meRes = await http.get(
          meUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverToken',
          },
        );
        final meJsonResp = meRes.body.isNotEmpty ? jsonDecode(meRes.body) : {};
        print('API /me response: ${meRes.statusCode} -> $meJsonResp');

        if (meRes.statusCode == 200 && meJsonResp['success'] == true) {
          final userProfile = meJsonResp['member']['userProfile'];
          final isApproved = userProfile['approved'] == true;

          // Save token to shared preferences
          await AuthService.saveToken(serverToken);

          if (isApproved) {
            // Navigate to BottomNav if profile is approved
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BottomNav(token: serverToken),
              ),
            );
          } else {
            // Navigate to TakeProfile if profile is not approved
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TakeProfile(token: serverToken),
              ),
            );
          }
        } else {
          // If /api/me fails, default to TakeProfile
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TakeProfile(token: serverToken),
            ),
          );
        }
      } else {
        final message =
            jsonResp['message'] ??
            jsonResp['error'] ??
            'Server verification failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e, st) {
      print('verify error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification error: $e')));
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      final data = <String, dynamic>{};
      if (_reqIdLocal != null) data['reqId'] = _reqIdLocal;
      // If you want to force SMS channel: data['retryChannel'] = 11;
      final resp = await OTPWidget.retryOTP(data);
      print('retryOTP resp: $resp');
      final newReq =
          resp?['reqId'] ?? resp?['request_id'] ?? resp?['requestId'];
      if (newReq != null) _reqIdLocal = newReq;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP resent')));
    } catch (e) {
      print('retry error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Resend error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber = '+91 ${widget.mobileNumber}';
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
              const Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: Color(0xFF0052CC),
              ),
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
                'Enter the OTP sent to $displayNumber',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // OTP inputs
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(OTP_LENGTH, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextField(
                      controller: _otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      cursorColor: const Color(0xFF0052CC),
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < OTP_LENGTH - 1)
                          FocusScope.of(context).nextFocus();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
              TextButton(
                onPressed: _resendOtp,
                child: Text(
                  "Resend OTP",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF0052CC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (widget.isDemo)
                const Text(
                  'Demo mode: OTP may be fixed in widget demo credentials',
                  style: TextStyle(color: Colors.orange),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
