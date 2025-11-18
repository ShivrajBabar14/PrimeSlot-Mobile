import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/profile.dart';

class AppointmentList extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedUserId;

  const AppointmentList({
    super.key,
    required this.selectedDate,
    required this.selectedUserId,
  });

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  late List<Map<String, dynamic>> appointments;
  bool isLoading = false; // Using dummy data, so no API loading

  @override
  void initState() {
    super.initState();

    // 🗓️ Dummy appointment data with title and location
    appointments = [
      {
        'title': 'Consultation Meeting',
        'firstName': 'John',
        'lastName': 'Doe',
        'appointmentDate': '2025-11-06',
        'appointmentTime': '10:00 AM - 10:30 AM',
        'phoneNumber': '+91 9876543210',
        'email': 'john.doe@example.com',
        'location': 'Zoom Call',
        'duration': 30,
      },
      {
        'title': 'Follow-up Discussion',
        'firstName': 'Emma',
        'lastName': 'Watson',
        'appointmentDate': '2025-11-06',
        'appointmentTime': '11:00 AM - 11:45 AM',
        'phoneNumber': '+91 9822334455',
        'email': 'emma.watson@example.com',
        'location': 'Google Meet',
        'duration': 45,
      },
      {
        'title': 'Health Check Consultation',
        'firstName': 'Amit',
        'lastName': 'Sharma',
        'appointmentDate': '2025-11-07',
        'appointmentTime': '02:00 PM - 02:30 PM',
        'phoneNumber': '+91 9876543211',
        'email': 'amit.sharma@example.com',
        'location': 'Clinic Room 2A',
        'duration': 30,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Filter appointments by selected date
    final filteredAppointments = appointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment['appointmentDate']);
      return appointmentDate.year == widget.selectedDate.year &&
          appointmentDate.month == widget.selectedDate.month &&
          appointmentDate.day == widget.selectedDate.day;
    }).toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Text(
          'No appointments scheduled for this date.',
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Meetings (${filteredAppointments.length})",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                final appointment = filteredAppointments[index];
                final timeParts = appointment['appointmentTime'].split(' - ');
                final startTime = timeParts.isNotEmpty ? timeParts[0] : '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 Title & Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              appointment['title'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            startTime,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      /// 🔹 Client Name with Profile Icon
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Profile(
                                    scaffoldKey: GlobalKey<ScaffoldState>(),
                                    token: '', // TODO: Pass actual token
                                  ),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFF0052CC),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${appointment['firstName']} ${appointment['lastName']}',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
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
                              appointment['location'],
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

                      /// 🔹 Action Buttons + Duration
                      Row(
                        children: [
                          _actionButton(Icons.call, "Call"),
                          const SizedBox(width: 12),
                          _actionButton(Icons.email_outlined, "Mail"),
                          const Spacer(),
                          Text(
                            '${appointment['duration']} min',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[700],
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

  /// 🔹 Reusable action button
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
