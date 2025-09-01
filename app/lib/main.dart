import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/library_screen.dart';
import 'screens/help_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sessions_screen.dart';
import 'utils/auth_service.dart';

void main() {
  runApp(const NazarRiyaApp());
}

class NazarRiyaApp extends StatefulWidget {
  const NazarRiyaApp({super.key});

  @override
  State<NazarRiyaApp> createState() => _NazarRiyaAppState();
}

class _NazarRiyaAppState extends State<NazarRiyaApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Clear any stored credentials on app start to ensure no auto-login
    _clearStoredCredentials();
  }

  Future<void> _clearStoredCredentials() async {
    final authService = AuthService();
    await authService.logout();
  }

  void _onLoginSuccess() {
    print('Main app - Login success callback called'); // Debug print
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NazarRiya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6B46C1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
      home: _isLoggedIn 
        ? HomeScreen(onLogout: _onLogout)
        : LoginScreen(onLoginSuccess: _onLoginSuccess),
      routes: {
        '/chat': (context) => const ChatScreen(),
        '/library': (context) => const LibraryScreen(),
        '/help': (context) => const HelpScreen(),
        '/profile': (context) => ProfileScreen(onLogout: _onLogout),
        '/sessions': (context) => const SessionsScreen(),
      },
    );
  }
}
