import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/showqr.dart';
import '../components/sidebar.dart';

class Profile extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Profile({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the profile
    const String name = "John Doe";
    const String email = "john.doe@example.com";
    const String mobile = "+1 (123) 456-7890";
    const String avatarUrl = "https://randomuser.me/api/portraits/men/1.jpg";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0052CC),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: const Sidebar(), // keep this if you want drawer active directly here
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildInfoTile(
              icon: Icons.phone_android,
              title: 'Mobile',
              subtitle: '+1 (123) 456-7890',
              color: Colors.green,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: 'john.doe@example.com',
              color: Colors.orange,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.qr_code_2,
                  color: Color(0xFF0052CC), size: 28),
              title: Text(
                'Show QR Code',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ShowQrDialog(
                    data: 'john.doe@example.com',
                    name: 'John Doe',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.montserrat(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
