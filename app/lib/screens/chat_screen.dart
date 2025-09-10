import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
import '../utils/auth_service.dart';
import '../utils/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentSessionId;
  ChatService? _chatService;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    print('Chat screen - Starting initialization...'); // Debug print
    logger.d('Initializing chat screen...');
    
    // Clear any existing messages first
    setState(() {
      _messages.clear();
    });
    
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    print('Chat screen - Is logged in: $isLoggedIn'); // Debug print
    logger.d('Is logged in: $isLoggedIn');
    
    if (isLoggedIn) {
      final token = await authService.getToken();
      final user = await authService.getUser();
      logger.d('Token exists: ${token != null}');
      logger.d('User exists: ${user != null}');
      
      if (token != null && user != null) {
        logger.d('Setting up chat service with token and user');
        setState(() {
          _chatService = ChatService(token);
          _currentUser = user;
        });
        
        // Check if we have a session ID from navigation
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          print('Chat screen - Navigation arguments: $args'); // Debug print
          logger.d('Navigation arguments: $args');
          
          if (args != null && args['sessionId'] != null) {
            final sessionId = args['sessionId'];
            print('Chat screen - Loading session history for: $sessionId'); // Debug print
            logger.d('Loading session history for: $sessionId');
            _loadSessionHistory(sessionId);
          } else {
            print('Chat screen - No session ID, adding welcome message'); // Debug print
            logger.d('Adding welcome message for new chat');
            // Add a small delay to ensure UI is ready
            await Future.delayed(const Duration(milliseconds: 100));
            _addWelcomeMessage();
          }
        });
      } else {
        logger.w('Token or user is null, showing login required');
        _showLoginRequired();
      }
    } else {
      logger.w('User not logged in, showing login required');
      _showLoginRequired();
    }
  }

  Future<void> _loadSessionHistory(String sessionId) async {
    print('Chat screen - _loadSessionHistory called with: $sessionId'); // Debug print
    if (_chatService == null) {
      print('Chat screen - _chatService is null, cannot load history'); // Debug print
      return;
    }
    
    try {
      print('Chat screen - Calling chat service to get session history'); // Debug print
      final history = await _chatService!.getSessionHistory(sessionId);
      print('Chat screen - History result: ${history != null ? 'success' : 'null'}'); // Debug print
      
      if (history != null) {
        print('Chat screen - Loading ${history.history.length} messages from history'); // Debug print
        // Decrypt messages first
        final decryptedMessages = <ChatMessage>[];
        for (final msg in history.history) {
          // Decrypt the message content
          final decryptedContent = await msg.decryptContent();
          decryptedMessages.add(ChatMessage(
            text: decryptedContent,
            isUser: msg.isUser,
            timestamp: DateTime.parse(msg.createdAt),
          ));
        }
        
        setState(() {
          _currentSessionId = sessionId;
          _messages.clear();
          _messages.addAll(decryptedMessages);
        });
        print('Chat screen - Session history loaded, total messages: ${_messages.length}'); // Debug print
      } else {
        print('Chat screen - History is null, adding welcome message'); // Debug print
        _addWelcomeMessage();
      }
    } catch (e) {
      print('Chat screen - Error loading session history: $e'); // Debug print
      logger.e('Error loading session history: $e');
      _addWelcomeMessage();
    }
  }

  void _showLoginRequired() {
    print('Chat screen - Showing login required message'); // Debug print
    // This will be handled by the parent widget
    // For now, show a message
    setState(() {
      _messages.add(ChatMessage(
        text: "Please log in to start chatting with Riya.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    print('Chat screen - Login required message added, total messages: ${_messages.length}'); // Debug print
  }

  void _addWelcomeMessage() {
    print('Chat screen - Adding welcome message'); // Debug print
    final welcomeMessage = ChatMessage(
      text: "Hi! I'm Riya. I'm here to have meaningful conversations about gender, consent, masculinity, and empathy. What would you like to talk about today?",
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
    
    print('Chat screen - Welcome message added, total messages: ${_messages.length}'); // Debug print
    logger.d('Welcome message added, total messages: ${_messages.length}');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_chatService == null) {
      _showLoginRequired();
      return;
    }

    // Add user message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      logger.d("Sending message: $text");
      
      // Send message using chat service
      final result = await _chatService!.sendMessage(text, sessionId: _currentSessionId);
      
      if (result.success) {
        // Update session ID if this is a new session
        if (_currentSessionId == null && result.sessionId != null) {
          _currentSessionId = result.sessionId;
        }
        
        final botMessage = ChatMessage(
          text: result.response ?? 'I understand. Please tell me more.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(botMessage);
          _isLoading = false;
        });
      } else {
        // Check if it's an authentication error
        if (result.error?.contains('Authentication expired') == true) {
          // Clear expired credentials and show login message
          final authService = AuthService();
          await authService.logout();
          
          final authMessage = ChatMessage(
            text: "Your session has expired. Please go back to the home screen and login again.",
            isUser: false,
            timestamp: DateTime.now(),
          );
          setState(() {
            _messages.add(authMessage);
            _isLoading = false;
          });
          
          // Show a snackbar to guide the user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session expired. Please login again.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          // Fallback response if API fails
          final fallbackMessage = ChatMessage(
            text: "I'm having trouble connecting right now. Let me know what's on your mind, and I'll do my best to help.",
            isUser: false,
            timestamp: DateTime.now(),
          );
          setState(() {
            _messages.add(fallbackMessage);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      logger.e("Error: $e");
      // Error handling
      final errorMessage = ChatMessage(
        text: "I'm experiencing some technical difficulties. Please try again in a moment.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }



  Future<void> _pickImage() async {
    // Image picking functionality will be implemented later
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image attachment coming soon!'),
        backgroundColor: Color(0xFF6B46C1),
      ),
    );
  }

  Future<void> _createNewSession() async {
    if (_chatService == null) return;
    
    try {
      final sessionId = await _chatService!.createNewSession();
      if (sessionId != null) {
        setState(() {
          _currentSessionId = sessionId;
          _messages.clear();
        });
        _addWelcomeMessage();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New chat session created!'),
            backgroundColor: Color(0xFF6B46C1),
          ),
        );
      }
    } catch (e) {
      logger.e('Error creating new session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create new session'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      await authService.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      logger.e('Error logging out: $e');
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



  @override
  Widget build(BuildContext context) {
    print('Chat screen - Building with ${_messages.length} messages'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSessionId != null ? 'Chat Session' : 'Chat with Riya'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        actions: [
          if (_chatService != null) ...[
            IconButton(
              onPressed: _createNewSession,
              icon: const Icon(Icons.add),
              tooltip: 'New Chat Session',
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [                
                // Text Input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                // Attachment Button (Coming Soon)
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                ),

                // Photo Button (Coming Soon)
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_camera, color: Colors.grey),
                ),

                // Voice Message Button (Disabled)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send Button
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFF6B46C1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF6B46C1),
              child: const Icon(Icons.psychology, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                  ? const Color(0xFF6B46C1) 
                  : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  

                  
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6B46C1),
            child: const Icon(Icons.psychology, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(1),
                _buildDot(2),
                _buildDot(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF6B46C1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }



  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
