import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/profile.dart';
import '../components/feedback.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const Sidebar({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    // Dummy user data
    const String userName = "John Doe";
    const String userEmail = "john.doe@example.com";
    const String avatarUrl = "https://randomuser.me/api/portraits/men/1.jpg";

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero, // Remove default ListView padding
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: GoogleFonts.montserrat(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.white,
            ),
            decoration: const BoxDecoration(color: Color(0xFF0052CC)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.black87),
            title: Text(
              'Profile',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer first

              // Call the callback to set profile tab active in bottom nav
              if (onProfileTap != null) {
                onProfileTap!();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined, color: Colors.black87),
            title: Text(
              'Share App',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              // TODO: Implement share app functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.star_rate_outlined,
              color: Colors.black87,
            ),
            title: Text(
              'Rate Us',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              // TODO: Implement rate us functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined, color: Colors.black87),
            title: Text(
              'Feedback',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // close drawer
              showDialog(
                context: context,
                builder: (context) => const FeedbackDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.black87),
            title: Text(
              'Settings',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              // TODO: Navigate to Settings screen
              Navigator.pop(context);
            },
          ),
          const Divider(), // A visual separator
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(
              'Logout',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
            onTap: () {
              // TODO: Implement logout functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
