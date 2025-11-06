import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardMeetings extends StatefulWidget {
  const DashboardMeetings({super.key});

  @override
  State<DashboardMeetings> createState() => _DashboardMeetingsState();
}

class _DashboardMeetingsState extends State<DashboardMeetings> {
  late List<Map<String, dynamic>> meetings;

  @override
  void initState() {
    super.initState();

    // 🗓️ Dummy meeting data
    meetings = [
      {
        'title': 'Team Sync Meeting',
        'clientName': 'John Doe',
        'time': '09:30 AM - 10:00 AM',
        'duration': 30,
        'location': 'Zoom',
        'email': 'john.doe@example.com',
        'phone': '+91 9876543210',
      },
      {
        'title': 'Project Review with Client',
        'clientName': 'Emma Watson',
        'time': '11:00 AM - 11:45 AM',
        'duration': 45,
        'location': 'Google Meet',
        'email': 'emma.watson@example.com',
        'phone': '+91 9822334455',
      },
      {
        'title': 'Internal Design Discussion',
        'clientName': 'Amit Sharma',
        'time': '02:00 PM - 02:45 PM',
        'duration': 45,
        'location': 'Office Meeting Room 3A',
        'email': 'amit.sharma@example.com',
        'phone': '+91 9898989898',
      },
      {
        'title': 'Evening Standup',
        'clientName': 'Team',
        'time': '05:00 PM - 05:15 PM',
        'duration': 15,
        'location': 'Slack Huddle',
        'email': 'team@company.com',
        'phone': '+91 9911223344',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Decide container height dynamically
    double cardHeight = 110; // average height per meeting card
    double totalHeight = (meetings.length * cardHeight) + 90; // +title + padding
    double maxHeight = 450; // max scrollable area height

    // If more than 3 meetings, limit height; else, auto-fit
    double containerHeight =
        totalHeight > maxHeight ? maxHeight : totalHeight.clamp(220, maxHeight);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      constraints: BoxConstraints(
        minHeight: 180, // Minimum height
        maxHeight: containerHeight, // Dynamic based on meeting count
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      /// 🔹 Main Content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Meetings (${meetings.length})",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: meetings.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No meetings scheduled for today',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: meetings.length > 3
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = meetings[index];
                      final startTime =
                          meeting['time'].toString().split('-').first.trim();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 Meeting title & time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    meeting['title'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  startTime,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            /// 🔹 Client Name
                            Text(
                              meeting['clientName'],
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),

                            /// 🔹 Location
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Color(0xFF0052CC),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    meeting['location'],
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            /// 🔹 Call / Mail buttons + duration
                            Row(
                              children: [
                                _actionButton(Icons.call, "Call"),
                                const SizedBox(width: 12),
                                _actionButton(Icons.email_outlined, "Mail"),
                                const Spacer(),
                                Text(
                                  '${meeting['duration']} min',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Reusable button
  Widget _actionButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2F4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
