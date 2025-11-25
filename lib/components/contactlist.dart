// contactlist.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'contactdetails.dart';

class ContactList extends StatefulWidget {
  final String token;

  const ContactList({super.key, required this.token});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final uri = Uri.parse(
        'https://prime-slotnew.vercel.app/api/profile/contacts',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          _contacts = decoded['contacts'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to fetch contacts (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: GoogleFonts.montserrat(color: Colors.red)),
      );
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Text(
          'No contacts found',
          style: GoogleFonts.montserrat(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 10),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index] as Map<String, dynamic>;

        final dynamic rawProfile = contact['profile'];
        Map<String, dynamic>? profile;
        if (rawProfile is Map<String, dynamic>) {
          profile = rawProfile;
        }

        final String fullName = contact['name'] ?? 'Unknown';
        final String email = contact['email'] ?? 'N/A';
        final String phone = contact['phone'] ?? 'N/A';

        final bool isApproved = profile?['approved'] == true;
        final Color borderColor = isApproved ? Colors.green : Colors.grey;

        final String avatarUrl =
            profile?['photoURL'] ??
            'https://via.placeholder.com/150.png?text=User';

        return Column(
          children: [
            InkWell(
              onTap: () {
                final mappedContact = {
                  'name': fullName,
                  'email': email,
                  'mobile': phone,
                  'avatarUrl': avatarUrl,
                  'businessName': contact['businessName'] ?? 'N/A',
                  'businessCategory': contact['businessCategory'] ?? 'N/A',
                  'chapterName': contact['chapterName'] ?? 'N/A',
                  'region': contact['region'] ?? 'N/A',
                  'city': contact['city'] ?? 'N/A',
                  'memberStatus': isApproved ? 'Active' : 'Inactive',
                  'trafficLight': isApproved ? "green" : "gray",
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactDetails(
                      contact: mappedContact,
                      token: widget.token,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(avatarUrl),
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Divider(
                height: 0,
                thickness: 1,
                color: Colors.grey.withOpacity(0.25),
              ),
            ),
          ],
        );
      },
    );
  }
}
