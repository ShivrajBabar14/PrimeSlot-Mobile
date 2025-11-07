import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    // Updated Dashboard Stats Data
    final List<Map<String, dynamic>> stats = [
      {
        'icon': Icons.calendar_month_outlined,
        'title': 'One to One',
        'value': '12',
        'color': const Color(0xFF2E94EE), // Blue
      },
      {
        'icon': Icons.event_available_outlined,
        'title': 'Upcoming Events',
        'value': '5',
        'color': const Color(0xFF00C853), // Green
      },
      {
        'icon': Icons.share_outlined,
        'title': 'Reference Shared',
        'value': '9',
        'color': const Color(0xFFFFA000), // Amber
      },
      {
        'icon': Icons.business_center_outlined,
        'title': 'Business Received',
        'value': '4',
        'color': const Color(0xFFE53935), // Red
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),

        // ✅ Fix: Use SingleChildScrollView to prevent overflow
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: stats.map((item) {
              return Container(
                width: 90, // fixed width for uniformity
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'],
                        color: item['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['value'],
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.5,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
