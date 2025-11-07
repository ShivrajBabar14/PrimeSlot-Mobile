import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  // Dummy contact data
  final List<Map<String, dynamic>> _contactData = [
    {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Emma Watson',
      'email': 'emma.watson@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Amit Sharma',
      'email': 'amit.sharma@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Sophia Loren',
      'email': 'sophia.loren@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Chris Hemsworth',
      'email': 'chris.hemsworth@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: _contactData.length,
      itemBuilder: (context, index) {
        final contact = _contactData[index];

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Navigate to contact details or chat
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    /// Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(contact['avatarUrl']),
                    ),
                    const SizedBox(width: 12),

                    /// Contact Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact['name'],
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact['email'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /// 🔹 Divider below every contact (including last)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 0.9,
                height: 0,
              ),
            ),
          ],
        );
      },
    );
  }
}
