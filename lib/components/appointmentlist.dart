import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  @override
  void didUpdateWidget(covariant AppointmentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _fetchMeetings();
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<String?> _getCurrentUserMemberId() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('https://prime-slotnew.vercel.app/api/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['memberId'];
      }
      return null;
    } catch (e) {
      print('Error fetching current user memberId: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchMemberDetails(String memberId) async {
    try {
      final response = await http.get(
        Uri.parse('https://prime-slotnew.vercel.app/api/members/$memberId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['member'] != null) {
          final member = data['member'];
          return {
            'fullName': member['fullName'],
            'email': member['email'],
            'phone': member['phone'],
            'photoURL': member['userProfile']?['photoURL'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error fetching member details for $memberId: $e');
      return null;
    }
  }

  /// 🔹 Helper: normalize epoch (seconds or ms) → milliseconds
  int _normalizeToMillis(dynamic raw) {
    if (raw == null) return 0;

    int value;
    if (raw is int) {
      value = raw;
    } else if (raw is String) {
      value = int.tryParse(raw) ?? 0;
    } else {
      return 0;
    }

    // If less than 1e12, it’s almost certainly in SECONDS → convert to ms
    if (value < 1000000000000) {
      value *= 1000;
    }
    return value;
  }

  /// 🔹 Helper: convert epoch ms (UTC) → IST DateTime
  DateTime _toIstFromMillis(int epochMillis) {
    // Treat the stored value as UTC epoch millis
    final utc = DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true);
    // IST = UTC + 5:30
    return utc.add(const Duration(hours: 5, minutes: 30));
  }

  Future<void> _fetchMeetings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final currentUserMemberId = await _getCurrentUserMemberId();
      if (currentUserMemberId == null) {
        throw Exception('Unable to fetch current user memberId');
      }

      final response = await http.get(
        Uri.parse('https://prime-slotnew.vercel.app/api/meetings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Meetings API response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meetings'] != null && data['meetings'] is List) {
          final meetings = data['meetings'] as List;
          final processedAppointments = <Map<String, dynamic>>[];

          for (var meeting in meetings) {
            final aId = meeting['aId'];
            final bId = meeting['bId'];
            final memberIdToFetch =
                (currentUserMemberId == aId) ? bId : aId;

            if (memberIdToFetch != null) {
              final memberDetails =
                  await _fetchMemberDetails(memberIdToFetch);
              print('Member details for $memberIdToFetch: $memberDetails');

              if (memberDetails != null) {
                // 🔹 scheduledAt handling (seconds OR ms → IST)
                final rawScheduledAt = meeting['scheduledAt'];
                final scheduledAtMillis = _normalizeToMillis(rawScheduledAt);

                if (scheduledAtMillis == 0) continue;

                final istStart = _toIstFromMillis(scheduledAtMillis);

                // Optional debug:
                print(
                  'Meeting ${meeting['meetingId']} '
                  '→ raw: $rawScheduledAt, '
                  'millis: $scheduledAtMillis, '
                  'IST: $istStart',
                );

                // 🔹 endTime handling: prefer backend endTime if present
                DateTime istEnd;
                if (meeting['endTime'] != null) {
                  final endMillis =
                      _normalizeToMillis(meeting['endTime']);
                  istEnd = _toIstFromMillis(endMillis);
                } else {
                  final durationMin = meeting['durationMin'] ?? 30;
                  istEnd = istStart.add(Duration(minutes: durationMin));
                }

                // 🔹 Format date (yyyy-MM-dd) in IST
                final formattedDate =
                    '${istStart.year}-${istStart.month.toString().padLeft(2, '0')}-${istStart.day.toString().padLeft(2, '0')}';

                // 🔹 Format time (hh:mm AM/PM) in IST
                String _formatTime(DateTime dt) {
                  final h = dt.hour;
                  final hour12 =
                      h > 12 ? h - 12 : (h == 0 ? 12 : h);
                  final period = h >= 12 ? 'PM' : 'AM';
                  return '${hour12.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
                }

                final formattedTime = _formatTime(istStart);
                final formattedEndTime = _formatTime(istEnd);

                final durationMin = meeting['durationMin'] ?? 30;

                processedAppointments.add({
                  'id': meeting['meetingId'],
                  'memberId': memberIdToFetch,
                  'title': meeting['topic'] ?? 'No topic',
                  'fullName': memberDetails['fullName'] ?? 'Unknown User',
                  'appointmentDate': formattedDate, // 🔹 IST date
                  'appointmentTime':
                      '$formattedTime - $formattedEndTime', // 🔹 IST times
                  'phoneNumber': memberDetails['phone'] ?? '',
                  'email': memberDetails['email'] ?? '',
                  'location': meeting['place'] ?? 'Not specified',
                  'duration': durationMin,
                  'photoURL': memberDetails['photoURL'],
                  'scheduledAt': scheduledAtMillis, // stored as ms
                });
              }
            }
          }

          setState(() {
            appointments = processedAppointments;
            isLoading = false;
          });
        } else {
          setState(() {
            appointments = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception(
          'Failed to fetch meetings: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching meetings: $e');
      setState(() {
        errorMessage = 'Failed to load appointments. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Error Loading Appointments",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? "Something went wrong. Please try again.",
              style: GoogleFonts.montserrat(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMeetings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052CC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Retry",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 🔹 Filter appointments by selected IST date
    final filteredAppointments = appointments.where((appointment) {
      final appointmentDate =
          DateTime.parse(appointment['appointmentDate']); // IST date
      return appointmentDate.year == widget.selectedDate.year &&
          appointmentDate.month == widget.selectedDate.month &&
          appointmentDate.day == widget.selectedDate.day;
    }).toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Text(
          'No appointments scheduled for this date.',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[600],
          ),
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
                final timeParts =
                    appointment['appointmentTime'].split(' - ');
                final startTime =
                    timeParts.isNotEmpty ? timeParts[0] : '';

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
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                            onTap: () async {
                              final token = await _getToken();
                              if (token != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Profile(
                                      scaffoldKey:
                                          GlobalKey<ScaffoldState>(),
                                      token: token,
                                      memberId:
                                          appointment['memberId'] != null
                                              ? appointment['memberId']
                                                  .toString()
                                              : null,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  appointment['photoURL'] != null &&
                                          appointment['photoURL'].isNotEmpty
                                      ? NetworkImage(
                                          appointment['photoURL'],
                                        )
                                      : null,
                              child: appointment['photoURL'] == null ||
                                      appointment['photoURL'].isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: const Color(0xFF0052CC),
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appointment['fullName'],
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
                          _actionButton(Icons.call, "Call", appointment),
                          const SizedBox(width: 12),
                          _actionButton(
                            Icons.email_outlined,
                            "Mail",
                            appointment,
                          ),
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
  Widget _actionButton(
    IconData icon,
    String label,
    Map<String, dynamic> appointment,
  ) {
    return GestureDetector(
      onTap: () {
        if (label == "Call") {
          print("Call ${appointment['phoneNumber']}");
        } else if (label == "Mail") {
          print("Email ${appointment['email']}");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE2F4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }
}
