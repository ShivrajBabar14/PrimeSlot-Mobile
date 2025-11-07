import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    // Stats data
    final List<Map<String, dynamic>> stats = [
      {
        'icon': Icons.calendar_today,
        'title': 'Appointments',
        'value': '45',
        'color': const Color(0xFF4ABAFD),
      },
      {
        'icon': Icons.check_circle,
        'title': 'Completed',
        'value': '32',
        'color': Colors.green,
      },
      {
        'icon': Icons.payment,
        'title': 'Received',
        'value': '\$2,500',
        'color': Colors.orange,
      },
      {
        'icon': Icons.pending_actions,
        'title': 'Pending',
        'value': '\$750',
        'color': Colors.red,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.map((item) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['value'],
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['title'],
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
