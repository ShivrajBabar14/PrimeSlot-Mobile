import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/sidebar.dart';
import '../components/chatlist.dart';

class Message extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const Message({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF0052CC),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Chats',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: Sidebar(),
      body: const ChatList(),
    );
  }
}
