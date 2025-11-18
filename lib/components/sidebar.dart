import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/profile.dart';
import '../screens/login.dart';
import '../components/feedback.dart';
import '../components/showqr.dart';
import '../services/auth_service.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final String token;

  const Sidebar({super.key, this.onProfileTap, required this.token});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isLoading = true;
  String userName = "Loading...";
  String userEmail = "Loading...";
  String avatarUrl = "https://randomuser.me/api/portraits/men/1.jpg";
  String memberId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
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
          setState(() {
            userName = data['member']['fullName'] ?? 'N/A';
            userEmail = data['member']['email'] ?? 'N/A';
            avatarUrl = data['member']['userProfile']['photoURL'] ?? 'https://randomuser.me/api/portraits/men/1.jpg';
            // Extract memberId from photoURL path
            String photoURL = data['member']['userProfile']['photoURL'] ?? '';
            if (photoURL.isNotEmpty) {
              // Extract memberId from URL like: https://storage.googleapis.com/prime-slot-35cd9.firebasestorage.app/profiles/-Oe0oEDnI4EG4PUiQ4BB/profile_1763454437759.png
              RegExp regExp = RegExp(r'/profiles/([^/]+)/');
              Match? match = regExp.firstMatch(photoURL);
              if (match != null && match.groupCount >= 1) {
                memberId = match.group(1)!;
              }
            }
            print('Fetched memberId: $memberId');
            print('Full member data: ${data['member']}');
            isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch user data');
        }
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        userName = 'Error loading';
        userEmail = 'Error loading';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 🔹 Header Section with gradient background
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0052CC), // Primary blue
                        Color(0xFF4C8BF5), // Lighter blue blend
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      // First row: Profile icon in center
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(avatarUrl),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Second row: Name, email, and QR icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 📝 Name and email
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userEmail,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 🎟 QR Icon
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => ShowQrDialog(
                                  data: memberId,
                                  name: userName,
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                color: Color(0xFF0052CC),
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 🔸 Menu Section
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Profile(scaffoldKey: GlobalKey<ScaffoldState>(), token: widget.token),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const FeedbackDialog(),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.share_outlined,
              title: 'Share App',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.star_rate_outlined,
              title: 'Rate Us',
              onTap: () => Navigator.pop(context),
            ),
            

            const Divider(height: 30, thickness: 0.5, color: Colors.grey),

            // 🚪 Logout Button
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              onTap: () async {
                Navigator.pop(context);
                // Clear token and navigate to login
                await AuthService.removeToken();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Sidebar Tile Widget
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0FF), // Soft tint of 0xFF0052CC
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
