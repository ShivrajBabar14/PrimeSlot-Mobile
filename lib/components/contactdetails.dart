import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../components/sidebar.dart';

class ContactDetails extends StatefulWidget {
  final Map<String, dynamic> contact;
  final String token;

  const ContactDetails({super.key, required this.contact, required this.token});

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  bool isLoading = true;
  Map<String, dynamic> member = {};
  String photoURL = '';
  String memberId = '';

  @override
  void initState() {
    super.initState();
    memberId = widget.contact["memberId"];
    _fetchMemberDetails();
  }

  Future<void> _fetchMemberDetails() async {
    try {
      final url = "https://prime-slotnew.vercel.app/api/members/$memberId";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          member = data['member'];
          photoURL = member['userProfile']?['photoURL'] ?? '';
          isLoading = false;
        });
      } else {
        throw "Status ${response.statusCode}";
      }
    } catch (e) {
      print("❌ Error fetching details: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBlue = const Color(0xFF0052CC);
    final trafficColor = _getTrafficLightColor(
      member['trafficLight'] ?? "green",
    );

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
          "Contact Details",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildProfileHeader(trafficColor),
                  _buildSectionCard("Personal Information", [
                    _buildTile(
                      Icons.phone_android,
                      "Mobile",
                      member['phone'] ?? "N/A",
                      Colors.green,
                    ),
                    _buildTile(
                      Icons.location_city,
                      "City",
                      member['city'] ?? "N/A",
                      Colors.indigo,
                    ),
                    _buildTile(
                      Icons.location_on,
                      "Region",
                      member['region'] ?? "N/A",
                      Colors.red,
                    ),
                  ]),
                  _buildSectionCard("Business Information", [
                    _buildTile(
                      Icons.business,
                      "Business Name",
                      member['businessName'] ?? "N/A",
                      Colors.blue,
                    ),
                    _buildTile(
                      Icons.category,
                      "Category",
                      member['businessCategory'] ?? "N/A",
                      Colors.purple,
                    ),
                    _buildTile(
                      Icons.group,
                      "Chapter",
                      member['chapterName'] ?? "N/A",
                      Colors.teal,
                    ),
                    _buildTrafficLightTile(),
                  ]),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(Color trafficColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: trafficColor, width: 3),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                photoURL.isNotEmpty
                    ? photoURL
                    : 'https://via.placeholder.com/150',
              ),
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            member['fullName'] ?? "N/A",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            member['email'] ?? "N/A",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: trafficColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Status: ${member['memberStatus'] ?? 'N/A'}",
              style: GoogleFonts.montserrat(
                color: trafficColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
          ),
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
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLightTile() {
    final trafficColor = _getTrafficLightColor(
      member['trafficLight'] ?? "green",
    );

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
                Text(
                  "Traffic Light",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "${member['trafficLight']}".toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrafficLightColor(String value) {
    switch (value.toLowerCase()) {
      case "green":
        return Colors.green;
      case "amber":
        return Colors.amber;
      case "grey":
      case "gray":
        return Colors.grey;
      case "red":
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
