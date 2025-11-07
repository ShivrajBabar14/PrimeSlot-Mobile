import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Contacts extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const Contacts({super.key, this.scaffoldKey});

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
      body: Center(
        child: Text('Contacts Screen', style: GoogleFonts.montserrat(fontSize: 24)),
      ),
    );
  }
}
