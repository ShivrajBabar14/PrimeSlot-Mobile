import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../components/sidebar.dart';
import '../components/dashboardappo.dart';
import '../components/dashboardstats.dart';
import '../components/pendingrequest.dart';

class Dashboard extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const Dashboard({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF0052CC),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: Text('Dashboard', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PendingRequest()),
                  );
                },
              ),
              if (PendingRequest.getPendingRequestsCount() > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      PendingRequest.getPendingRequestsCount().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DashboardStats(), // Replace with actual user ID
            const DashboardMeetings(),
          ],
        ),
      ),
    );
  }
}
