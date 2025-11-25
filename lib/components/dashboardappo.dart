import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/profile.dart';

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
    final isPM = h >= 12;
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return "$hour12:$m ${isPM ? 'PM' : 'AM'}";
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
      if (currentUserId == null) throw "Current user not found";

      final res = await http.get(
        Uri.parse("https://prime-slotnew.vercel.app/api/meetings"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      final data = jsonDecode(res.body);
      final meetings = data["meetings"] ?? [];

      List<Map<String, dynamic>> temp = [];
      DateTime now = DateTime.now();

      for (var m in meetings) {
        String? otherId = currentUserId == m["aId"] ? m["bId"] : m["aId"];
        if (otherId == null) continue;

        final member = await _fetchMember(otherId);
        if (member == null) continue;

        final startMillis = _normalizeToMillis(m["scheduledAt"]);
        if (startMillis == 0) continue;

        final startIST = _toIST(startMillis);

        if (startIST.year == now.year &&
            startIST.month == now.month &&
            startIST.day == now.day) {
          temp.add({
            "title": m["topic"] ?? "New Meeting",
            "fullName": member["fullName"] ?? "Unknown User",
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
    double cardHeight = 120;
    double totalHeight = (todaysMeetings.length * cardHeight) + 90;
    double maxHeight = 450;

    double containerHeight = totalHeight > maxHeight
        ? maxHeight
        : totalHeight.clamp(220, maxHeight);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: containerHeight),
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
                          physics: todaysMeetings.length > 3
                              ? const BouncingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
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
          /// Title + time
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
                  overflow: TextOverflow.ellipsis, // ✅ correct place
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
              _actionButton(Icons.call, "Call"),
              const SizedBox(width: 12),
              _actionButton(Icons.email_outlined, "Mail"),
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

  Widget _actionButton(IconData icon, String label) {
    return Container(
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
    );
  }
}
