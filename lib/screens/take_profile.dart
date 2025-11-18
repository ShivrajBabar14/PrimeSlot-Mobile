import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'profile_approval_screen.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class TakeProfile extends StatefulWidget {
  final String token;

  const TakeProfile({super.key, required this.token});

  @override
  State<TakeProfile> createState() => _TakeProfileState();
}

class _TakeProfileState extends State<TakeProfile> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      PermissionStatus permissionStatus;
      if (source == ImageSource.camera) {
        permissionStatus = await Permission.camera.request();
      } else {
        permissionStatus = await Permission.photos.request();
      }

      if (permissionStatus.isGranted) {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });

          bool success = await _uploadProfileImage();

          if (success) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileApprovalScreen(
                  selectedImage: _selectedImage,
                  token: widget.token,
                ),
              ),
            );
          }
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        // Open app settings if permission is permanently denied
        openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Permission denied. Please enable ${source == ImageSource.camera ? 'camera' : 'gallery'} permission in settings.",
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${source == ImageSource.camera ? 'Camera' : 'Gallery'} permission denied.",
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to pick image: $e",
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<bool> _uploadProfileImage() async {
    if (_selectedImage == null) return false;

    try {
      var uri = Uri.parse(
        "https://prime-slotnew.vercel.app/api/profile/upload",
      );

      var request = http.MultipartRequest('POST', uri);

      // HEADER
      request.headers.addAll({
        "Authorization": "Bearer ${widget.token}",
        "Accept": "application/json",
      });

      // 🔥 Detect MIME type
      final mimeType = lookupMimeType(_selectedImage!.path) ?? "image/jpeg";
      final mimeSplit = mimeType.split('/');

      // 🔥 Attach file with correct MIME type
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _selectedImage!.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]), // ⭐ FIXED
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("UPLOAD RESPONSE BODY → $responseBody");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("UPLOAD FAILED → ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("UPLOAD ERROR → $e");
      return false;
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Choose Image Source",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0052CC)),
                title: Text("Camera", style: GoogleFonts.montserrat()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF0052CC),
                ),
                title: Text("Gallery", style: GoogleFonts.montserrat()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0052CC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Take Profile Picture",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Color(0xFF0052CC),
              ),
              const SizedBox(height: 20),
              Text(
                "Add a Profile Picture",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Choose from camera or gallery to set your profile picture",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  label: Text(
                    "Select Profile Picture",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 5,
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
