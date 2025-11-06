import 'package:flutter/material.dart';
import '../components/sidebar.dart';

class Message extends StatelessWidget {
  const Message({super.key});

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
        title: Text('Messages'),
      ),
      drawer: Sidebar(),
      body: Center(
        child: Text('Messages Page'),
      ),
    );
  }
}
