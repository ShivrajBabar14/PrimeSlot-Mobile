import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // Dummy chat data
  final List<Map<String, dynamic>> _chatData = [
    {
      'name': 'John Doe',
      'lastMessage': 'Hey, how are you? Let\'s catch up soon!',
      'time': '10:45 AM',
      'notificationCount': 3,
      'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Emma Watson',
      'lastMessage': 'See you tomorrow! Don\'t forget the documents.',
      'time': '9:30 AM',
      'notificationCount': 1,
      'avatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Amit Sharma',
      'lastMessage': 'Okay, sounds good.',
      'time': 'Yesterday',
      'notificationCount': 0,
      'avatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Sophia Loren',
      'lastMessage': 'Can you send me the file? It\'s urgent.',
      'time': 'Mon',
      'notificationCount': 2,
      'avatarUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Chris Hemsworth',
      'lastMessage': 'Thanks!',
      'time': 'Sun',
      'notificationCount': 0,
      'avatarUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: _chatData.length,
      itemBuilder: (context, index) {
        final chat = _chatData[index];
        final hasNotification = chat['notificationCount'] > 0;

        return Column(
          children: [
            InkWell(
              onTap: () {
                // TODO: Navigate to chat details
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    /// Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(chat['avatarUrl']),
                    ),
                    const SizedBox(width: 12),

                    /// Chat Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat['name'],
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chat['lastMessage'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              color: hasNotification
                                  ? Colors.black.withOpacity(0.75)
                                  : Colors.grey[600],
                              fontWeight: hasNotification
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// Time + Notification
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          chat['time'],
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: hasNotification
                                ? const Color(0xFF0052CC)
                                : Colors.grey[500],
                            fontWeight: hasNotification
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (hasNotification)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0052CC),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                chat['notificationCount'].toString(),
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// 🔹 Divider below every chat (including last)
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
