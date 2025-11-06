import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/appointment.dart';
import '../screens/message.dart';
import '../screens/profile.dart';
import '../components/scanqr.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final _pages = const [
    Dashboard(), // 0 - Home
    Appointment(), // 1 - Appointments
    Message(), // 2 - Messages
    Profile(), // 3 - Profile
  ];

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanQR()),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;
    const Color active = Color(0xFF0052CC); // Bright blue
    const Color inactive = Color(0xFF9E9E9E); // Muted grey

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Icon(
          icon,
          size: 26,
          color: selected ? active : inactive,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          onPressed: _openScanner,
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
              Transform.translate(
                offset: const Offset(0, -5),
                child: _buildTab(icon: Icons.home_rounded, index: 0),
              ),
              Transform.translate(
                offset: const Offset(0, -5),
                child: _buildTab(icon: Icons.event_note_rounded, index: 1),
              ),

              // Space for QR FAB
              const SizedBox(width: 48),

              // Right 2 tabs
              Transform.translate(
                offset: const Offset(0, -5),
                child: _buildTab(icon: Icons.message_rounded, index: 2),
              ),
              Transform.translate(
                offset: const Offset(0, -5),
                child: _buildTab(icon: Icons.person_rounded, index: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
