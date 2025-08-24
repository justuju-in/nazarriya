import 'package:flutter/material.dart';
import '../utils/chat_service.dart';
import '../utils/auth_service.dart';
import '../utils/app_logger.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;
  ChatService? _chatService;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      
      if (token != null) {
        _chatService = ChatService(token);
        final sessions = await _chatService!.getUserSessions();
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading sessions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      if (_chatService != null) {
        final success = await _chatService!.deleteSession(sessionId);
        if (success) {
          setState(() {
            _sessions.removeWhere((session) => session.id == sessionId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error deleting session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete session'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshSessions() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Sessions'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshSessions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Sessions',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B46C1),
              ),
            )
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No chat sessions yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation to create your first session',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshSessions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6B46C1),
                            child: Text(
                              session.title.isNotEmpty 
                                ? session.title[0].toUpperCase()
                                : 'C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            session.title.isNotEmpty 
                              ? session.title 
                              : 'Untitled Session',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${session.messageCount} messages',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Created: ${_formatDate(session.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteDialog(session);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to chat with this session
                            Navigator.pushNamed(
                              context, 
                              '/chat',
                              arguments: {'sessionId': session.id},
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showDeleteDialog(ChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete "${session.title.isNotEmpty ? session.title : 'Untitled Session'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSession(session.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
