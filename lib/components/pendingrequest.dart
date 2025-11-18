import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PendingRequest extends StatefulWidget {
  const PendingRequest({super.key});

  // Static method to get pending requests count
  static int getPendingRequestsCount() {
    // Return 0 for now since we can't access instance variable statically
    // This will be updated when we implement proper state management
    return 0;
  }

  @override
  State<PendingRequest> createState() => _PendingRequestState();
}

class _PendingRequestState extends State<PendingRequest> {
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
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

  Future<void> _fetchPendingRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await http.get(
        Uri.parse('https://prime-slotnew.vercel.app/api/members/meetings/pending'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Pending requests API response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meetings'] != null && data['meetings'] is List) {
          final meetings = data['meetings'] as List;
          final processedRequests = <Map<String, dynamic>>[];

          for (var meeting in meetings) {
            final bId = meeting['bId'];
            if (bId != null) {
              // Fetch member details for each bId
              final memberDetails = await _fetchMemberDetails(bId);
              print('Member details for $bId: $memberDetails');
              if (memberDetails != null) {
                // Convert scheduledAt timestamp to local time
                final scheduledAt = meeting['scheduledAt'];
                final dateTime = DateTime.fromMillisecondsSinceEpoch(scheduledAt * 1000);
                final localDateTime = dateTime.toLocal();

                final formattedDate = '${localDateTime.day}/${localDateTime.month}/${localDateTime.year}';
                final hour = localDateTime.hour > 12 ? localDateTime.hour - 12 : (localDateTime.hour == 0 ? 12 : localDateTime.hour);
                final period = localDateTime.hour >= 12 ? 'PM' : 'AM';
                final formattedTime = '${hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')} $period';

                processedRequests.add({
                  'id': meeting['meetingId'],
                  'requesterName': memberDetails['fullName'] ?? 'Unknown User',
                  'photoURL': memberDetails['photoURL'],
                  'date': formattedDate,
                  'time': formattedTime,
                  'location': meeting['place'] ?? 'Not specified',
                  'topic': meeting['topic'] ?? 'No topic',
                  'status': 'pending',
                });
              }
            }
          }

          setState(() {
            _pendingRequests = processedRequests;
            _isLoading = false;
          });
        } else {
          setState(() {
            _pendingRequests = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch pending requests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
      setState(() {
        _errorMessage = 'Failed to load pending requests. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchMemberDetails(String memberId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('https://prime-slotnew.vercel.app/api/members/$memberId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['member'] != null) {
          final member = data['member'];
          return {
            'fullName': member['fullName'],
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
          "Pending Requests",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _pendingRequests.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pending_actions, color: mainBlue, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              "Meeting Requests",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: mainBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Review and respond to meeting requests from other users",
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Requests List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = _pendingRequests[index];
                      return _buildRequestCard(request, mainBlue);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final Color mainBlue = const Color(0xFF0052CC);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No Pending Requests",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You don't have any meeting requests to review",
            style: GoogleFonts.montserrat(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final Color mainBlue = const Color(0xFF0052CC);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Error Loading Requests",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? "Something went wrong. Please try again.",
            style: GoogleFonts.montserrat(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchPendingRequests,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildRequestCard(Map<String, dynamic> request, Color mainBlue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Requester Name and Photo
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: request['photoURL'] != null && request['photoURL'].isNotEmpty
                    ? NetworkImage(request['photoURL'])
                    : null,
                child: request['photoURL'] == null || request['photoURL'].isEmpty
                    ? Icon(Icons.person, color: mainBlue, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request['requesterName'],
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meeting Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // Date and Time Row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            request['date'],
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            request['time'],
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request['location'],
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Reject Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectRequest(request['id']),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.red.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Reject",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Accept Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(request['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Accept",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Authentication error. Please login again.",
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('https://prime-slotnew.vercel.app/api/members/meetings/$requestId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Accept request API response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _pendingRequests.removeWhere((request) => request['id'] == requestId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Meeting request accepted successfully!",
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to accept request: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error accepting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to accept meeting request. Please try again.",
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Authentication error. Please login again.",
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('https://prime-slotnew.vercel.app/api/members/meetings/$requestId/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Reject request API response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _pendingRequests.removeWhere((request) => request['id'] == requestId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Meeting request rejected",
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Failed to reject request: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to reject meeting request. Please try again.",
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
