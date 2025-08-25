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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    print('Main app - Auth status check: $isLoggedIn'); // Debug print
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  void _onLoginSuccess() {
    print('Main app - Login success callback called'); // Debug print
    // Refresh auth status to ensure consistency
    _checkAuthStatus();
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology,
                  size: 80,
                  color: Color(0xFF6B46C1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nazarriya',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B46C1),
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  color: Color(0xFF6B46C1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'NazarRiya',
      debugShowCheckedModeBanner: false,
      // navigatorKey: _navigatorKey, // Removed as per edit hint
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
