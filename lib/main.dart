import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'components/bottmnav.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final token = await AuthService.getToken();
        if (token != null) {
          final isValid = await AuthService.validateToken(token);
          if (isValid) {
            setState(() {
              _initialScreen = BottomNav(token: token);
            });
          } else {
            // Token invalid, remove it and show login
            await AuthService.removeToken();
            setState(() {
              _initialScreen = const LoginScreen();
            });
          }
        } else {
          setState(() {
            _initialScreen = const LoginScreen();
          });
        }
      } else {
        setState(() {
          _initialScreen = const LoginScreen();
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _initialScreen = const LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // 👈 This removes the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _initialScreen ?? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
