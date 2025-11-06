import 'package:flutter/material.dart';
import '../components/sidebar.dart';

class Appointment extends StatelessWidget {
  const Appointment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Center(
        child: Text('Appointments Page'),
      ),
    );
  }
}
