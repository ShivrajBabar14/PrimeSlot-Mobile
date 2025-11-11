import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingRequest extends StatefulWidget {
  const PendingRequest({super.key});

  // Static method to get pending requests count
  static int getPendingRequestsCount() {
    return _PendingRequestState._pendingRequests.length;
  }

  @override
  State<PendingRequest> createState() => _PendingRequestState();
}

class _PendingRequestState extends State<PendingRequest> {
  // Mock data for pending meeting requests - made static for access from Dashboard
  static final List<Map<String, dynamic>> _pendingRequests = [
    {
      'id': '1',
      'requesterName': 'John Smith',
      'date': '15/12/2024',
      'time': '10:00 AM',
      'location': 'Conference Room A',
      'status': 'pending',
    },
    {
      'id': '2',
      'requesterName': 'Sarah Johnson',
      'date': '16/12/2024',
      'time': '2:00 PM',
      'location': 'Virtual Meeting',
      'status': 'pending',
    },
    {
      'id': '3',
      'requesterName': 'Mike Davis',
      'date': '17/12/2024',
      'time': '11:00 AM',
      'location': 'Cafeteria',
      'status': 'pending',
    },
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
          "Pending Requests",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _pendingRequests.isEmpty
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
          // Requester Name
          Row(
            children: [
              Icon(Icons.person, color: mainBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                request['requesterName'],
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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

  void _acceptRequest(String requestId) {
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
  }

  void _rejectRequest(String requestId) {
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
  }
}
