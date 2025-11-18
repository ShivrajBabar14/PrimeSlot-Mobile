import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/showqr.dart';
import '../components/sidebar.dart';

class Profile extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String token;
  final String? memberId;

  const Profile({super.key, required this.scaffoldKey, required this.token, this.memberId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  Map<String, dynamic> member = {};
  String photoURL = '';
  String memberId = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final url = widget.memberId != null
          ? 'https://prime-slotnew.vercel.app/api/members/${widget.memberId}'
          : 'https://prime-slotnew.vercel.app/api/me';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final memberData = data['member'] ?? data;
        setState(() {
          member = memberData;
          photoURL = memberData['userProfile']?['photoURL'] ?? '';
          // Extract memberId from photoURL path or use provided memberId
          if (widget.memberId != null) {
            memberId = widget.memberId!;
          } else {
            String photoURLTemp = memberData['userProfile']?['photoURL'] ?? '';
            if (photoURLTemp.isNotEmpty) {
              // Extract memberId from URL like: https://storage.googleapis.com/prime-slot-35cd9.firebasestorage.app/profiles/-Oe0oEDnI4EG4PUiQ4BB/profile_1763454437759.png
              RegExp regExp = RegExp(r'/profiles/([^/]+)/');
              Match? match = regExp.firstMatch(photoURLTemp);
              if (match != null && match.groupCount >= 1) {
                memberId = match.group(1)!;
              }
            }
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final Color mainBlue = const Color(0xFF0052CC);
    final trafficColor = _getTrafficLightColor(member['trafficLight']?.toString().toLowerCase() ?? 'green');

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
          "Profile",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: Sidebar(token: widget.token),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            backgroundImage: NetworkImage(photoURL.isNotEmpty ? photoURL : 'https://randomuser.me/api/portraits/men/1.jpg'),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          member['fullName'] ?? 'N/A',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member['email'] ?? 'N/A',
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
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Status: ${member['memberStatus'] ?? 'N/A'}",
                            style: GoogleFonts.montserrat(
                              color: Colors.green,
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
                      _buildTile(Icons.phone_android, "Mobile", member['phone'] ?? 'N/A', Colors.green),
                      _buildTile(Icons.location_city, "City", member['city'] ?? 'N/A', Colors.indigo),
                      _buildTile(Icons.location_on, "Region", member['region'] ?? 'N/A', Colors.red),
                    ],
                  ),

                  // 🔹 Business Info Card
                  _buildSectionCard(
                    title: "Business Information",
                    children: [
                      _buildTile(Icons.business, "Business Name", member['businessName'] ?? 'N/A', Colors.blue),
                      _buildTile(Icons.category, "Business Category", member['businessCategory'] ?? 'N/A', Colors.purple),
                      _buildTile(Icons.group, "Chapter Name", member['chapterName'] ?? 'N/A', Colors.teal),
                      _buildTrafficLightTile(),
                    ],
                  ),


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
  Widget _buildTrafficLightTile() {
    final trafficColor = _getTrafficLightColor(member['trafficLight']?.toString().toLowerCase() ?? 'green');
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
                  (member['trafficLight'] ?? 'green').toString().toUpperCase(),
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

  // Traffic Color Logic
  Color _getTrafficLightColor(String light) {
    switch (light.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.amber;
      case 'grey':
        return Colors.grey;
      case 'red':
        return Colors.red;
      default:
        return Colors.green;
    }
  }


}
