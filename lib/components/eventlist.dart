import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'itenary.dart';

class UpcomingEvents extends StatelessWidget {
  const UpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for upcoming events
    final List<Map<String, dynamic>> events = [
      {
        'title': 'Flutter Workshop',
        'date': '2025-11-12',
        'description': 'Learn the basics of Flutter development in this hands-on session.',
        'enrolled': 150,
        'assigned': 200,
      },
      {
        'title': 'Tech Conference',
        'date': '2025-11-20',
        'description': 'Join leading industry experts for the annual tech summit.',
        'enrolled': 400,
        'assigned': 500,
      },
      {
        'title': 'Hackathon',
        'date': '2025-11-25',
        'description': 'Participate in our 24-hour innovation challenge.',
        'enrolled': 75,
        'assigned': 100,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Title
          Text(
            'Upcoming Events',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0052CC),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Events List
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventItinerary(
                            event: {
                              ...event,
                              'image': 'https://picsum.photos/400/200?random=${index + 1}',
                            },
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🖼️ Top Image
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/400/200?random=${index + 1}',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // 📝 Event Details Below Image
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event['title']!,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2F0FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${event['enrolled']}/${event['assigned']}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0052CC),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: Color(0xFF0052CC)),
                                  const SizedBox(width: 6),
                                  Text(
                                    event['date']!,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                event['description']!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.5,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
