import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EventItinerary extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventItinerary({super.key, required this.event});

  @override
  State<EventItinerary> createState() => _EventItineraryState();
}

class _EventItineraryState extends State<EventItinerary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Event Itinerary',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🖼️ Event Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  widget.event['image'] ??
                      'https://picsum.photos/400/200?random=1',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Event Title and Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title
                Text(
                  widget.event['title'] ?? 'BizMania 26 — Event Day Itinerary',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0052CC),
                  ),
                ),
                const SizedBox(height: 0),

                // Tabs
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF0052CC),
                        width: 3.0, // Thicker indicator line
                      ),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor:
                      Colors.transparent, // Remove default indicator
                  indicatorWeight: 0, // Remove default indicator weight
                  labelColor: const Color(0xFF0052CC),
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Itinerary'),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                _buildDetailsContent(),
                // Itinerary Tab
                _buildItineraryContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Itinerary Items
          _buildItineraryItem(
            time: '5:45 AM – 6:00 AM',
            title: 'LT\'s Parade',
            description: '',
          ),
          _buildItineraryItem(
            time: '6:00 AM – 10:00 AM',
            title: 'Hexa - Centennial Meeting',
            description: '600+ members with Lightning business intros🔥',
          ),
          _buildItineraryItem(
            time: '10:00 AM – 11:00 AM',
            title: 'Networking Breakfast',
            description: '',
          ),
          _buildItineraryItem(
            time: '10:30 AM – 2:00 PM',
            title: '121 Round Table Conclave',
            description:
                '(4 rounds x 8 members)\nVendor Empanelment\n(Pitching to Companies)\nVVIP Welcome & Visit to Stalls',
          ),
          _buildItineraryItem(
            time: '1:30 PM to 2:30 PM',
            title: 'Networking Lunch',
            description: '',
          ),
          _buildItineraryItem(
            time: '3:00 PM to 3:30 PM',
            title: 'Session on expanding Business in Brazil',
            description: '121 Conclave continues',
          ),
          _buildItineraryItem(
            time: '3:30 PM to 4:30 PM',
            title: 'BizMania Battle Tank',
            description: '121 Conclave Continues',
          ),
          _buildItineraryItem(
            time: '4:30 PM to 5:00 PM',
            title: 'Speaker session',
            description: '121 Conclave continues',
          ),
          _buildItineraryItem(
            time: '5:00 PM to 5:30 PM',
            title: 'Dus ka Dum Awards',
            description: '',
          ),
          _buildItineraryItem(
            time: '5:30 PM to 6:00 PM',
            title: 'Networking Hi - Tea',
            description: '',
          ),

          const SizedBox(height: 30),

          // Footer Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0052CC).withOpacity(0.2),
              ),
            ),
            child: Text(
              'We\'ll have a detailed briefing in Jan to understand how to utilise BizMania 26 to the fullest.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Date & Time in Single Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0052CC).withOpacity(0.1),
                child: const Icon(Icons.calendar_today,
                    color: Color(0xFF0052CC), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event['date'] ?? 'November 12, 2025',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          widget.event['time'] ?? '9:00 AM - 6:00 PM',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🔹 Description Section
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About the Event',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0052CC),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.event['description'] ??
                    'Join us for an extraordinary experience of networking, learning, and collaboration with business leaders and innovators.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Venue Card with Mini Map
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(Icons.location_on, color: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Venue",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF0052CC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.event['address'] ?? 'Convention Center, New Delhi',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Static Google Map Preview (replace YOUR_API_KEY if needed)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "https://maps.googleapis.com/maps/api/staticmap?center=${Uri.encodeComponent(widget.event['address'] ?? 'New Delhi')}&zoom=14&size=600x300&markers=color:red%7C${Uri.encodeComponent(widget.event['address'] ?? 'New Delhi')}&key=YOUR_API_KEY",
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.map, color: Colors.grey, size: 50),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.event['address'] ?? 'Convention Center, New Delhi')}';
                  _launchUrl(url);
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052CC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        "View on Google Maps",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        
      ],
    ),
  );
}


  // 👇 Add this helper for launching Google Maps
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Fallback: try to launch without external application mode
      try {
        final Uri uri = Uri.parse(url);
        if (!await launchUrl(uri)) {
          throw 'Could not launch $url';
        }
      } catch (fallbackError) {
        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open maps. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
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

  Widget _buildItineraryItem({
    required String time,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          Container(
            width: 80,
            child: Text(
              time,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0052CC),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
