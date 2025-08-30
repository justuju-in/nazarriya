import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/profile_service.dart';
import '../utils/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  
  const ProfileScreen({super.key, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  
  String? _selectedLanguage;
  String? _selectedState;
  String? _selectedGender;
  String? _selectedBot;
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _clearProfileData();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile data when dependencies change (e.g., when navigating to this screen)
    _refreshProfileIfNeeded();
  }

  Future<void> _refreshProfileIfNeeded() async {
    final authService = AuthService();
    final currentUser = await authService.getUser();
    
    // If the current user is different from what we have, reload the profile
    if (currentUser != null && 
        (_currentUser == null || currentUser['email'] != _currentUser!['email'])) {
      _loadProfile();
    }
  }

  void _clearProfileData() {
    // Clear all form fields and state variables
    _firstNameController.clear();
    _ageController.clear();
    _selectedLanguage = null;
    _selectedState = null;
    _selectedGender = null;
    _selectedBot = null;
    _currentUser = null;
  }

  Future<void> _loadProfile() async {
    try {
      // First clear all previous data to prevent showing previous user's settings
      setState(() {
        _firstNameController.clear();
        _ageController.clear();
        _selectedLanguage = null;
        _selectedState = null;
        _selectedGender = null;
        _selectedBot = null;
        _currentUser = null;
      });
      
      final authService = AuthService();
      
      // Check if user is authenticated
      final isLoggedIn = await authService.isLoggedIn();
      if (!isLoggedIn) {
        setState(() {
          _isLoading = false;
        });
        await _handleAuthFailure();
        return;
      }
      
      final user = await authService.getUser();
      
      if (user != null) {
        setState(() {
          _currentUser = user;
          _firstNameController.text = user['first_name'] ?? '';
          _ageController.text = user['age']?.toString() ?? '';
          _selectedLanguage = user['preferred_language'];
          _selectedState = user['state'];
          _selectedGender = ProfileService.codeToGender(user['gender']);
          _selectedBot = ProfileService.codeToBot(user['preferred_bot']);
        });
      } else {
        // If no user data found, redirect to login
        setState(() {
          _isLoading = false;
        });
        await _handleAuthFailure();
        return;
      }
      
      // Also load local profile data as fallback
      final profile = await ProfileService.getProfile();
      setState(() {
        _firstNameController.text = _firstNameController.text.isEmpty 
          ? (profile['firstName'] ?? '') 
          : _firstNameController.text;
        _ageController.text = _ageController.text.isEmpty 
          ? (profile['age']?.toString() ?? '') 
          : _ageController.text;
        _selectedLanguage = _selectedLanguage ?? profile['preferredLanguage'];
        _selectedState = _selectedState ?? profile['state'];
        _selectedGender = _selectedGender ?? ProfileService.codeToGender(profile['gender']);
        _selectedBot = _selectedBot ?? ProfileService.codeToBot(profile['preferredBot']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
    });
    await _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // First save to local storage for offline access
        await ProfileService.saveProfile(
          firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : null,
          age: _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
          gender: ProfileService.genderToCode(_selectedGender),
          preferredLanguage: _selectedLanguage,
          state: _selectedState,
          preferredBot: ProfileService.botToCode(_selectedBot),
        );
        
        // Then update the backend database via API
        final authService = AuthService();
        final result = await authService.updateProfile(
          firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : null,
          age: _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
          gender: ProfileService.genderToCode(_selectedGender),
          preferredLanguage: _selectedLanguage,
          state: _selectedState,
          preferredBot: ProfileService.botToCode(_selectedBot),
        );
        
        if (result.success) {
          // Update local user data with the updated profile
          if (result.user != null) {
            setState(() {
              _currentUser = result.user;
            });
          }
          
          // Clear local profile data after successful save to prevent conflicts
          await ProfileService.clearProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving profile: ${result.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      await authService.logout();
      
      if (mounted) {
        // Use the onLogout callback if provided, otherwise navigate directly
        if (widget.onLogout != null) {
          // Call the logout callback to trigger main app rebuild
          widget.onLogout!();
          // Then navigate back to previous screen (emulating back button)
          Navigator.pop(context);
        } else {
          // Fallback: Navigate to login screen and clear all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAuthFailure() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to access your profile'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'User Profile',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6B46C1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B46C1),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: const Color(0xFF6B46C1),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Icon and User Info
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B46C1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: const Color(0xFF6B46C1),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF6B46C1),
                          ),
                        ),
                        if (_currentUser != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _currentUser!['email'] ?? '',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_currentUser!['phone_number'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _currentUser!['phone_number'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // First Name Field
                  Text(
                    'First Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your first name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Age Field
                  Text(
                    'Age',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter your age',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final age = int.tryParse(value);
                        if (age == null || age < 1 || age > 120) {
                          return 'Please enter a valid age (1-120)';
                        }
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gender Field
                  Text(
                    'Gender',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    menuMaxHeight: 200,
                    decoration: InputDecoration(
                      hintText: 'Select your gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: AppConstants.genderOptions.map((gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(
                          gender,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preferred Bot Field
                  Text(
                    'Preferred Bot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedBot,
                    isExpanded: true,
                    menuMaxHeight: 200,
                    decoration: InputDecoration(
                      hintText: 'Select your preferred bot',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: AppConstants.botOptions.map((bot) {
                      return DropdownMenuItem<String>(
                        value: bot,
                        child: Text(
                          bot,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBot = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preferred Language Field
                  Text(
                    'Preferred Language',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    menuMaxHeight: 200,
                    decoration: InputDecoration(
                      hintText: 'Select your preferred language',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: AppConstants.languages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(
                          language,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // State Field
                  Text(
                    'State',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    isExpanded: true,
                    menuMaxHeight: 200,
                    decoration: InputDecoration(
                      hintText: 'Select your state',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: AppConstants.indianStates.map((state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(
                          state,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
