import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/dashboard.dart';
import '../screens/appointment.dart';
import '../screens/events.dart';
import '../screens/contacts.dart';
import '../components/scanqr.dart';
import '../components/sidebar.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final _pages = [
    Dashboard(scaffoldKey: _scaffoldKey, token: ''), // TODO: Pass actual token
    Appointment(scaffoldKey: _scaffoldKey, token: ''), // TODO: Pass actual token
    Events(scaffoldKey: _scaffoldKey, token: ''), // TODO: Pass actual token
    Contacts(scaffoldKey: _scaffoldKey, token: ''), // TODO: Pass actual token
  ];

  Widget _buildTab({
    required String assetPath,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;
    const Color active = Color(0xFF0052CC); // Bright blue
    const Color inactive = Color(0xFF9E9E9E); // Muted grey

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 26,
            height: 26,
            colorFilter: ColorFilter.mode(
              selected ? active : inactive,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          // Active indicator dot
          Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              color: selected ? active : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: Sidebar(
        onProfileTap: () => setState(() => _selectedIndex = 3),
        token: '', // TODO: Pass actual token
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // Floating QR button (center)
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF0052CC),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQR())),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Custom BottomAppBar with a notch for the QR button
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left 2 tabs
              _buildTab(assetPath: 'assets/home.svg', index: 0),
              _buildTab(assetPath: 'assets/Appointment.svg', index: 1),

              // Space for QR FAB
              const SizedBox(width: 48),

              // Right 2 tabs
              _buildTab(assetPath: 'assets/message.svg', index: 2),
              _buildTab(assetPath: 'assets/people.svg', index: 3),
            ],
          ),
        ),
      ),
    );
  }
}
