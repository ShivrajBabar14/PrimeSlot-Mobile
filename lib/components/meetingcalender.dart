import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class MeetingCalendar extends StatefulWidget {
  final String scannedUserData;

  const MeetingCalendar({super.key, required this.scannedUserData});

  @override
  State<MeetingCalendar> createState() => _MeetingCalendarState();
}

class _MeetingCalendarState extends State<MeetingCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock data for current user and scanned user availability
  final Map<DateTime, List<String>> _currentUserBookedSlots = {
    DateTime(2024, 12, 15): ['10:00 AM', '2:00 PM'],
    DateTime(2024, 12, 16): ['9:00 AM', '3:00 PM'],
    DateTime(2024, 12, 17): ['11:00 AM'],
  };

  final Map<DateTime, List<String>> _scannedUserBookedSlots = {
    DateTime(2024, 12, 15): ['11:00 AM', '4:00 PM'],
    DateTime(2024, 12, 16): ['10:00 AM', '1:00 PM'],
    DateTime(2024, 12, 18): ['2:00 PM'],
  };

  // Available time slots (9 AM to 5 PM)
  final List<String> _allTimeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final Color mainBlue = const Color(0xFF0052CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      appBar: AppBar(
        backgroundColor: mainBlue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Schedule Meeting",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Available Meeting Slots",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select a date to view available time slots for both participants",
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: mainBlue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: mainBlue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: mainBlue,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selected Date Info
            if (_selectedDay != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Slots for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeSlotsGrid(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    final currentUserBooked = _currentUserBookedSlots[_selectedDay] ?? [];
    final scannedUserBooked = _scannedUserBookedSlots[_selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _buildLegendItem(Colors.green, "Available"),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.red, "Booked"),
          ],
        ),
        const SizedBox(height: 16),

        // Time slots grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: _allTimeSlots.length,
          itemBuilder: (context, index) {
            final slot = _allTimeSlots[index];
            final isCurrentUserBooked = currentUserBooked.contains(slot);
            final isScannedUserBooked = scannedUserBooked.contains(slot);
            final isAvailable = !isCurrentUserBooked && !isScannedUserBooked;

            return _buildTimeSlotButton(slot, isAvailable, isCurrentUserBooked, isScannedUserBooked);
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotButton(String slot, bool isAvailable, bool isCurrentUserBooked, bool isScannedUserBooked) {
    Color buttonColor;
    String statusText = "";

    if (isAvailable) {
      buttonColor = Colors.green;
      statusText = "Available";
    } else {
      buttonColor = Colors.red;
      if (isCurrentUserBooked && isScannedUserBooked) {
        statusText = "Both Booked";
      } else if (isCurrentUserBooked) {
        statusText = "You Booked";
      } else {
        statusText = "Other Booked";
      }
    }

    return ElevatedButton(
      onPressed: isAvailable ? () => _selectTimeSlot(slot) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor.withOpacity(0.1),
        foregroundColor: buttonColor,
        disabledBackgroundColor: buttonColor.withOpacity(0.1),
        disabledForegroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slot,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            statusText,
            style: GoogleFonts.montserrat(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _selectTimeSlot(String slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Meeting Request",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
              style: GoogleFonts.montserrat(),
            ),
            Text(
              "Time: $slot",
              style: GoogleFonts.montserrat(),
            ),
            const SizedBox(height: 16),
            Text(
              "This will send a meeting request to the other participant for approval.",
              style: GoogleFonts.montserrat(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.montserrat(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement meeting request logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Meeting request sent successfully!",
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
            ),
            child: Text(
              "Send Request",
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }
}
