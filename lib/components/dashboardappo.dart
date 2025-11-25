import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../screens/profile.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardMeetings extends StatefulWidget {
  final String token;

  const DashboardMeetings({super.key, required this.token});

  @override
  State<DashboardMeetings> createState() => _DashboardMeetingsState();
}

class _DashboardMeetingsState extends State<DashboardMeetings> {
  List<Map<String, dynamic>> todaysMeetings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<String?> _getCurrentUserId() async {
    final res = await http.get(
      Uri.parse("https://prime-slotnew.vercel.app/api/me"),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["memberId"];
    }
    return null;
  }

  int _normalizeToMillis(dynamic raw) {
    if (raw == null) return 0;
    int value = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
    if (value < 1000000000000) value *= 1000;
    return value;
  }

  DateTime _toIST(int epochMillis) {
    final utc = DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true);
    return utc.add(const Duration(hours: 5, minutes: 30));
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return "$hour12:$m ${h >= 12 ? 'PM' : 'AM'}";
  }

  Future<Map<String, dynamic>?> _fetchMember(String memberId) async {
    final res = await http.get(
      Uri.parse("https://prime-slotnew.vercel.app/api/members/$memberId"),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (res.statusCode == 200) {
      final member = jsonDecode(res.body)['member'];
      return {
        "fullName": member["fullName"],
        "email": member["email"],
        "phone": member["phone"],
        "photoURL": member["userProfile"]?["photoURL"],
      };
    }
    return null;
  }

  Future<void> _fetchMeetings() async {
    try {
      setState(() => isLoading = true);

      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) throw "User not found";

      final res = await http.get(
        Uri.parse("https://prime-slotnew.vercel.app/api/meetings"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      final data = jsonDecode(res.body);
      final meetings = data["meetings"] ?? [];

      List<Map<String, dynamic>> temp = [];
      DateTime today = DateTime.now();

      for (var m in meetings) {
        // SHOW ONLY MEETINGS WHERE USER IS INVOLVED (aId OR bId)
        if (m["aId"] != currentUserId && m["bId"] != currentUserId) continue;

        final otherId = m["aId"] == currentUserId ? m["bId"] : m["aId"];
        if (otherId == null) continue;

        final member = await _fetchMember(otherId);
        if (member == null) continue;

        final millis = _normalizeToMillis(m["scheduledAt"]);
        if (millis == 0) continue;

        final startIST = _toIST(millis);

        if (startIST.year == today.year &&
            startIST.month == today.month &&
            startIST.day == today.day) {
          temp.add({
            "title": m["topic"] ?? "New Meeting",
            "fullName": member["fullName"],
            "memberId": otherId,
            "photoURL": member["photoURL"],
            "location": m["place"] ?? "Not Assigned",
            "duration": m["durationMin"] ?? 30,
            "startTime": _formatTime(startIST),
            "phone": member["phone"],
            "email": member["email"],
          });
        }
      }

      setState(() {
        todaysMeetings = temp;
        isLoading = false;
      });
    } catch (e) {
      print("Dashboard Meetings Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = 450; // scrollable height box

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: maxHeight), // SCROLL ENABLED
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Meetings (${todaysMeetings.length})",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: todaysMeetings.isEmpty
                      ? const Center(
                          child: Text(
                            "No meetings scheduled for today!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: todaysMeetings.length,
                          itemBuilder: (context, index) =>
                              _buildMeetingCard(todaysMeetings[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  m["title"],
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                m["startTime"],
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Profile(
                      scaffoldKey: GlobalKey<ScaffoldState>(),
                      token: widget.token,
                      memberId: m["memberId"],
                    ),
                  ),
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: m["photoURL"] != null
                      ? NetworkImage(m["photoURL"])
                      : null,
                  child: m["photoURL"] == null
                      ? const Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF0052CC),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m["fullName"],
                  overflow: TextOverflow.ellipsis,
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
                  m["location"],
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

          Row(
            children: [
              _actionButton(Icons.call, "Call", m),
              const SizedBox(width: 12),
              _actionButton(Icons.email_outlined, "Mail", m),
              const Spacer(),
              Text(
                "${m["duration"]} min",
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
  }

  Widget _actionButton(IconData icon, String label, Map<String, dynamic> m) {
    return GestureDetector(
      onTap: () async {
        if (label == "Call") {
          final phone = m['phone'];
          final uri = Uri(scheme: 'tel', path: phone);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            print("Could not launch phone dialer");
          }
        } else if (label == "Mail") {
          final email = m['email'];
          final uri = Uri(
            scheme: 'mailto',
            path: email,
            query: 'subject=Meeting Follow-Up',
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            print("Could not launch email");
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.black87),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
