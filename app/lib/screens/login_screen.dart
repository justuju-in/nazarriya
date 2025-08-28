import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import '../utils/app_logger.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _preferredLanguageController = TextEditingController();
  final _stateController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _preferredLanguageController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      AuthResult result;

      if (_isLogin) {
        // For login, use either email or phone number
        final emailOrPhone = _emailController.text.trim();
        result = await authService.login(
          emailOrPhone: emailOrPhone,
          password: _passwordController.text,
        );
      } else {
        result = await authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim(),
          firstName: _firstNameController.text.trim().isEmpty 
            ? null 
            : _firstNameController.text.trim(),
          age: _ageController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_ageController.text.trim()),
          preferredLanguage: _preferredLanguageController.text.trim().isEmpty 
            ? null 
            : _preferredLanguageController.text.trim(),
          state: _stateController.text.trim().isEmpty 
            ? null 
            : _stateController.text.trim(),
        );
      }

      if (result.success) {
        logger.i('${_isLogin ? 'Login' : 'Registration'} successful');
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = result.error;
        });
        logger.e('${_isLogin ? 'Login' : 'Registration'} failed: ${result.error}');
      }
    } catch (e) {
      logger.e('Form submission error: $e');
      String errorMsg = 'An unexpected error occurred';
      
      // Provide more specific error messages
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        errorMsg = 'Cannot connect to server. Please check if the server is running.';
      } else if (e.toString().contains('404')) {
        errorMsg = 'Server endpoint not found. Please check server configuration.';
      } else if (e.toString().contains('500')) {
        errorMsg = 'Server internal error. Please try again later.';
      } else if (e.toString().contains('timeout')) {
        errorMsg = 'Request timed out. Please check your connection.';
      }
      
      setState(() {
        _errorMessage = errorMsg;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or App Name
              const SizedBox(height: 32),
              const Icon(
                Icons.psychology,
                size: 80,
                color: Color(0xFF6B46C1),
              ),
              const SizedBox(height: 16),
              Text(
                'Nazarriya',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF6B46C1),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _isLogin ? 'Email or Phone Number' : 'Email',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _isLogin ? 'Please enter your email or phone number' : 'Please enter your email';
                  }
                  if (!_isLogin && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Registration Fields (only show when registering)
              if (!_isLogin) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Basic phone number validation (allows international formats)
                    if (!RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final age = int.tryParse(value);
                      if (age == null || age < 13 || age > 120) {
                        return 'Please enter a valid age between 13 and 120';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _preferredLanguageController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Language (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State/Region (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isLogin ? 'Login' : 'Register',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),

              // Toggle Mode Button
              TextButton(
                onPressed: _isLoading ? null : _toggleMode,
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login',
                  style: const TextStyle(color: Color(0xFF6B46C1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
