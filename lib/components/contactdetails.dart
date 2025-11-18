import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/showqr.dart';
import '../components/sidebar.dart';

class ContactDetails extends StatelessWidget {
  final Map<String, dynamic> contact;
  final String token;

  const ContactDetails({super.key, required this.contact, required this.token});

  @override
  Widget build(BuildContext context) {
    // Extract data from contact map
    final String name = contact['name'] ?? 'Unknown';
    final String email = contact['email'] ?? 'N/A';
    final String mobile = contact['mobile'] ?? '+1 (123) 456-7890';
    final String avatarUrl = contact['avatarUrl'] ?? 'https://randomuser.me/api/portraits/men/1.jpg';
    final String businessName = contact['businessName'] ?? 'Business Name';
    final String businessCategory = contact['businessCategory'] ?? 'Category';
    final String chapterName = contact['chapterName'] ?? 'Chapter';
    final String region = contact['region'] ?? 'Region';
    final String city = contact['city'] ?? 'City';
    final String memberStatus = contact['memberStatus'] ?? 'Active';
    final String trafficLight = contact['trafficLight'] ?? 'green';

    final Color mainBlue = const Color(0xFF0052CC);
    final trafficColor = _getTrafficLightColor(trafficLight);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      appBar: AppBar(
        backgroundColor: mainBlue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Details',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: Sidebar(token: token),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 🔹 Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                // color: Colors.white,
                // borderRadius: BorderRadius.circular(20),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.1),
                //     blurRadius: 10,
                //     offset: const Offset(0, 5),
                //   ),
                // ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: trafficColor,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: trafficColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Status: $memberStatus",
                      style: GoogleFonts.montserrat(
                        color: trafficColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 0),

            // 🔹 Personal Info Card
            _buildSectionCard(
              title: "Personal Information",
              children: [
                _buildTile(Icons.phone_android, "Mobile", mobile, Colors.green),
                _buildTile(Icons.location_city, "City", city, Colors.indigo),
                _buildTile(Icons.location_on, "Region", region, Colors.red),
              ],
            ),

            // 🔹 Business Info Card
            _buildSectionCard(
              title: "Business Information",
              children: [
                _buildTile(Icons.business, "Business Name", businessName, Colors.blue),
                _buildTile(Icons.category, "Business Category", businessCategory, Colors.purple),
                _buildTile(Icons.group, "Chapter Name", chapterName, Colors.teal),
                _buildTrafficLightTile(trafficLight),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 QR Code Button
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: ElevatedButton.icon(
            //     style: ElevatedButton.styleFrom(
            //       minimumSize: const Size(double.infinity, 50),
            //       backgroundColor: mainBlue,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(14),
            //       ),
            //       elevation: 3,
            //     ),
            //     onPressed: () {
            //       showDialog(
            //         context: context,
            //         builder: (context) => ShowQrDialog(data: email, name: name),
            //       );
            //     },
            //     icon: const Icon(Icons.qr_code_2, color: Colors.white),
            //     label: Text(
            //       "Show QR Code",
            //       style: GoogleFonts.montserrat(
            //         color: Colors.white,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 16,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Section Card Widget
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0052CC),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // Info Row Widget
  Widget _buildTile(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.montserrat(
                        color: Colors.grey[600], fontSize: 12)),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Traffic Light Tile Widget
  Widget _buildTrafficLightTile(String trafficLight) {
    final trafficColor = _getTrafficLightColor(trafficLight);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: trafficColor.withOpacity(0.1),
            child: Icon(Icons.traffic, color: trafficColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Traffic Light",
                    style: GoogleFonts.montserrat(
                        color: Colors.grey[600], fontSize: 12)),
                Text(
                  trafficLight.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }



  Color _getTrafficLightColor(String light) {
    switch (light.toLowerCase()) {
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
}
