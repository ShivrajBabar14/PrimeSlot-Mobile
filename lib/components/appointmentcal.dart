import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const AppointmentCalendar({super.key, required this.onDateSelected});

  @override
  State<AppointmentCalendar> createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends State<AppointmentCalendar> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 30; // Default to today (30th index since we start from -30 days)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    _scrollController.animateTo(
      30 * 58.0, // Approximate width per item (50 width + 8 margin)
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Generate dates from 30 days ago to 30 days ahead
  List<DateTime> _generateDates() {
    final List<DateTime> dates = [];
    final DateTime today = DateTime.now();
    for (int i = -30; i < 30; i++) {
      dates.add(today.add(Duration(days: i)));
    }
    return dates;
  }

  String _getDayName(DateTime date) {
    const List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _getMonthAbbr(DateTime date) {
    const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> dates = _generateDates();

    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      color: Color(0xFFF3F3F3),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onDateSelected(date);
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0052CC), Color.fromARGB(255, 143, 197, 245)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day} ${_getMonthAbbr(date)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
