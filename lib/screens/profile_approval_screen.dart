import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/bottmnav.dart';

class ProfileApprovalScreen extends StatefulWidget {
  final File? selectedImage;
  final String token;
  const ProfileApprovalScreen({super.key, this.selectedImage, required this.token});

  @override
  State<ProfileApprovalScreen> createState() => _ProfileApprovalScreenState();
}

class _ProfileApprovalScreenState extends State<ProfileApprovalScreen> {
  bool showRequestField = false;
  final TextEditingController _messageController = TextEditingController();
  String get selectedTrafficLight => userInfo['trafficLight'] ?? 'green';

  // 🧩 Dummy user data (replace with actual API response)
  final Map<String, dynamic> userInfo = {
    'photo':
        'https://randomuser.me/api/portraits/men/11.jpg',
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+91 9876543210',
    'businessName': 'Health & Wellness Co.',
    'businessCategory': 'Healthcare',
    'chapterName': 'Delhi Chapter',
    'region': 'North India',
    'city': 'New Delhi',
    'memberStatus': 'Active',
    'trafficLight': 'green',
  };

  void _approveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Profile approved successfully!",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNav()),
    );
  }

  void _sendUpdateRequest() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a message for profile update request.",
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Request sent successfully!",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0052CC),
      ),
    );

    setState(() {
      showRequestField = false;
      _messageController.clear();
    });
  }

  Color getTrafficLightColor(String light) {
    switch (light) {
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.amber;
      case 'gray':
        return Colors.grey;
      case 'red':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0052CC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Confirm Your Profile",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔹 Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: getTrafficLightColor(selectedTrafficLight),
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: widget.selectedImage != null
                          ? FileImage(widget.selectedImage!)
                          : NetworkImage(userInfo['photo']),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userInfo['name'],
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userInfo['email'],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Profile Info List
                  _infoTile("Phone", userInfo['phone'] ?? 'N/A'),
                  _infoTile("Business Name", userInfo['businessName'] ?? 'N/A'),
                  _infoTile("Business Category", userInfo['businessCategory'] ?? 'N/A'),
                  _infoTile("Chapter Name", userInfo['chapterName'] ?? 'N/A'),
                  _infoTile("Region", userInfo['region'] ?? 'N/A'),
                  _infoTile("City", userInfo['city'] ?? 'N/A'),
                  _infoTile("Member Status", userInfo['memberStatus'] ?? 'N/A'),
                  _infoTile("Traffic Light", selectedTrafficLight.toUpperCase(), textColor: getTrafficLightColor(selectedTrafficLight)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔹 Action Buttons
            if (!showRequestField) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _approveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 5,
                  ),
                  child: Text(
                    "Approve Profile",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => showRequestField = true),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0052CC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Request Profile Update",
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF0052CC),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            /// 🔹 Update Request Field
            if (showRequestField) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _messageController,
                maxLines: 4,
                cursorColor: const Color(0xFF0052CC),
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Type your message here...",
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD6E4FF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0052CC),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendUpdateRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Send Request",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔹 Info tile builder
  Widget _infoTile(String label, String value, {Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }


}
