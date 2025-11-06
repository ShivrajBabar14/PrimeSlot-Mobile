import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/sidebar.dart';
import '../components/chatlist.dart';

class Message extends StatelessWidget {
  const Message({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF0052CC),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Chats', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      drawer: Sidebar(),
      body: const ChatList(),
    );
  }
}
