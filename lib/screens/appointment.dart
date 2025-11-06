import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/sidebar.dart';
import '../components/appointmentcal.dart';
import '../components/appointmentlist.dart';

class Appointment extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const Appointment({super.key, this.scaffoldKey});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  DateTime selectedDate = DateTime.now();
  String selectedUserId = "user123"; // Dummy user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF0052CC),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            widget.scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: Text('Meetings', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          AppointmentCalendar(
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          Expanded(
            child: AppointmentList(
              selectedDate: selectedDate,
              selectedUserId: selectedUserId,
            ),
          ),
        ],
      ),
    );
  }
}
