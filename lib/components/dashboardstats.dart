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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: stats.map((item) {
            return Container(
              width: 70, // reduced width
              margin: const EdgeInsets.symmetric(horizontal: 4), // reduced margin
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10), // reduced padding
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: 20, // reduced icon size
                    ),
                  ),
                  const SizedBox(height: 8), // reduced spacing
                  Text(
                    item['value'],
                    style: GoogleFonts.montserrat(
                      fontSize: 16, // reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4), // reduced spacing
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 11, // reduced font size
                      color: Colors.grey[700],
                      height: 1.2, // adjusted line height
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
