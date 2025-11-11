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

  // Mock data
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

  final List<String> _allTimeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM',
    '3:00 PM', '4:00 PM', '5:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final Color mainBlue = const Color(0xFF0052CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainBlue,
        title: Text(
          "Schedule Meeting",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(mainBlue),
            const SizedBox(height: 20),
            _buildCalendar(mainBlue),
            const SizedBox(height: 20),
            if (_selectedDay != null) _buildSlotCard(mainBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(Color mainBlue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainBlue.withOpacity(0.9), mainBlue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find Available Slots",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Select a date to check both users' available meeting times.",
            style: GoogleFonts.montserrat(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Color mainBlue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(color: mainBlue, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: mainBlue.withOpacity(0.3), shape: BoxShape.circle),
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: mainBlue),
          rightChevronIcon: Icon(Icons.chevron_right, color: mainBlue),
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 16, fontWeight: FontWeight.w600, color: mainBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(Color mainBlue) {
    final currentUserBooked = _currentUserBookedSlots[_selectedDay] ?? [];
    final scannedUserBooked = _scannedUserBookedSlots[_selectedDay] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Slots — ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
            style: GoogleFonts.montserrat(
              fontSize: 16, fontWeight: FontWeight.bold, color: mainBlue,
            ),
          ),
          const SizedBox(height: 14),
          _buildLegend(),
          const SizedBox(height: 20),

          // Responsive compact grid: minimum 3 per row
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // 5 cols on very wide, 4 on medium, minimum 3 on normal phones
              final crossAxisCount = width >= 720 ? 5 : (width >= 560 ? 4 : 3);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _allTimeSlots.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3.2, // compact cards
                ),
                itemBuilder: (context, index) {
                  final slot = _allTimeSlots[index];
                  final isCurrentUserBooked = currentUserBooked.contains(slot);
                  final isScannedUserBooked = scannedUserBooked.contains(slot);
                  final isAvailable = !isCurrentUserBooked && !isScannedUserBooked;

                  return _buildCompactSlotCard(
                    slot,
                    isAvailable,
                    isCurrentUserBooked,
                    isScannedUserBooked,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.green.shade600, "Available"),
        const SizedBox(width: 20),
        _legendItem(Colors.red.shade500, "Booked"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // NEW: compact slot card (previously missing)
  Widget _buildCompactSlotCard(
    String slot,
    bool isAvailable,
    bool isCurrentUserBooked,
    bool isScannedUserBooked,
  ) {
    Color statusColor;
    Gradient gradient;

    if (isAvailable) {
      gradient = const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
      statusColor = Colors.green.shade700;
    } else if (isCurrentUserBooked && isScannedUserBooked) {
      gradient = const LinearGradient(
        colors: [Color(0xFFFFCDD2), Color(0xFFE57373)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
      statusColor = Colors.red.shade700;
    } else if (isCurrentUserBooked) {
      gradient = const LinearGradient(
        colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
      statusColor = Colors.orange.shade700;
    } else {
      gradient = const LinearGradient(
        colors: [Color(0xFFFFCDD2), Color(0xFFFFAB91)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
      statusColor = Colors.red.shade600;
    }

    return InkWell(
      onTap: isAvailable ? () => _selectTimeSlot(slot) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.28)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Text(
          slot,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 13, fontWeight: FontWeight.w600, color: statusColor,
          ),
        ),
      ),
    );
  }

  void _selectTimeSlot(String slot) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 48, color: Colors.blue.shade700),
              const SizedBox(height: 16),
              Text(
                "Confirm Meeting Request",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}\nTime: $slot",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Text(
                "This will send a meeting request to the other participant for approval.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Cancel", style: GoogleFonts.montserrat(color: Colors.blue.shade700)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green.shade600,
                          content: Text(
                            "Meeting request sent successfully!",
                            style: GoogleFonts.montserrat(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Send Request", style: GoogleFonts.montserrat(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
