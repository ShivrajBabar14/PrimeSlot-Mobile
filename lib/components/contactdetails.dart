import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../components/showqr.dart';
import '../components/sidebar.dart';

class ContactDetails extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactDetails({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the contact (extend as needed)
    final String name = contact['name'] ?? 'Unknown';
    final String email = contact['email'] ?? 'N/A';
    final String mobile = contact['mobile'] ?? '+1 (123) 456-7890';
    final String avatarUrl = contact['avatarUrl'] ?? 'https://randomuser.me/api/portraits/men/1.jpg';
    final String businessName = contact['businessName'] ?? 'Business Name';
    final String businessCategory = contact['businessCategory'] ?? 'Category';
    final String chapterName = contact['chapterName'] ?? 'Chapter';
    final String region = contact['region'] ?? 'Region';
    final String city = contact['city'] ?? 'City';
    final String memberStatus = contact['memberStatus'] ?? 'Status';

  
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0052CC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Contact Details',
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
            CircleAvatar(
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
    // Extract data from contact map
    final String mobile = contact['mobile'] ?? '+1 (123) 456-7890';
    final String email = contact['email'] ?? 'N/A';
    final String businessName = contact['businessName'] ?? 'Business Name';
    final String businessCategory = contact['businessCategory'] ?? 'Category';
    final String chapterName = contact['chapterName'] ?? 'Chapter';
    final String region = contact['region'] ?? 'Region';
    final String city = contact['city'] ?? 'City';
    final String memberStatus = contact['memberStatus'] ?? 'Status';
    final String name = contact['name'] ?? 'Unknown';

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
              subtitle: mobile,
              color: Colors.green,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: email,
              color: Colors.orange,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.business,
              title: 'Business Name',
              subtitle: businessName,
              color: Colors.blue,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.category,
              title: 'Business Category',
              subtitle: businessCategory,
              color: Colors.purple,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.group,
              title: 'Chapter Name',
              subtitle: chapterName,
              color: Colors.teal,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.location_on,
              title: 'Region',
              subtitle: region,
              color: Colors.red,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.location_city,
              title: 'City',
              subtitle: city,
              color: Colors.indigo,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              icon: Icons.verified_user,
              title: 'Member Status',
              subtitle: memberStatus,
              color: Colors.green,
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
