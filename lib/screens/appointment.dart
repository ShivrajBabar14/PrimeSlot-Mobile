import 'package:flutter/material.dart';
import '../components/sidebar.dart';
import '../components/appointmentcal.dart';
import '../components/appointmentlist.dart';

class Appointment extends StatefulWidget {
  const Appointment({super.key});

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
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Appointments'),
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
