import 'package:flutter/material.dart';
import '../components/sidebar.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
        title: Text('Profile'),
      ),
      drawer: Sidebar(),
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
