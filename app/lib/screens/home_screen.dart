import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              Text(
                'NazarRiya',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: const Color(0xFF6B46C1),
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'Talk. Question. Change.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Logo Placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: const Color(0xFF6B46C1),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 60,
                  color: Color(0xFF6B46C1),
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Main Action Buttons
              _buildActionButton(
                context,
                'Chat with Riya and Nazar',
                Icons.chat_bubble_outline,
                () => Navigator.pushNamed(context, '/chat'),
              ),
              
              const SizedBox(height: 20),
              
              _buildActionButton(
                context,
                'Browse our Library',
                Icons.library_books_outlined,
                () => Navigator.pushNamed(context, '/library'),
              ),
              
              const SizedBox(height: 20),
              
              _buildActionButton(
                context,
                'Call our Helpline',
                Icons.phone_outlined,
                () => Navigator.pushNamed(context, '/help'),
              ),
              
              const Spacer(),
              
              // Profile Icon at Bottom Center
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF6B46C1),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF6B46C1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B46C1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
