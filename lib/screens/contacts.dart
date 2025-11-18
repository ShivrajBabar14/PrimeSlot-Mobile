import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/contactlist.dart';

class Contacts extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String token;

  const Contacts({super.key, this.scaffoldKey, required this.token});

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
        title: Text('Contacts', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: ContactList(token: token),
    );
  }
}
