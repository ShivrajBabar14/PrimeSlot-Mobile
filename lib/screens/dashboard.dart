import 'package:flutter/material.dart';
import '../components/sidebar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

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
        title: Text('Dashboard'),
      ),
      drawer: Sidebar(),
      body: Center(
        child: Text('Dashboard Page'),
      ),
    );
  }
}
