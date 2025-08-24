import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

class ChatService {
  final String _baseUrl;
  final String _token;

  ChatService(this._token) : _baseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<ChatResult> sendMessage(String message, {String? sessionId}) async {
    try {
      final url = '$_baseUrl/api/chat';
      final body = {
        'message': message,
        'session_id': sessionId,
      };
      
      logger.d('Sending message: POST $url');
      logger.d('Request body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        logger.i('Message sent successfully. Session: ${data['session_id']}');
        return ChatResult.success(
          sessionId: data['session_id'],
          response: data['response'],
          sources: data['sources'] != null 
            ? List<String>.from(data['sources']) 
            : null,
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Failed to send message';
        logger.e('Send message failed (${response.statusCode}): $errorMessage');
        logger.e('Full error response: ${response.body}');
        return ChatResult.error(errorMessage);
      }
    } catch (e) {
      logger.e('Send message network error: $e');
      return ChatResult.error('Network error: $e');
    }
  }

  Future<List<ChatSession>> getUserSessions({int limit = 50, int offset = 0}) async {
    try {
      final url = '$_baseUrl/api/sessions?limit=$limit&offset=$offset';
      logger.d('Getting user sessions: GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        logger.i('Retrieved ${data.length} sessions successfully');
        return data.map((session) => ChatSession.fromJson(session)).toList();
      } else {
        logger.e('Failed to get sessions (${response.statusCode}): ${response.body}');
        return [];
      }
    } catch (e) {
      logger.e('Get sessions network error: $e');
      return [];
    }
  }

  Future<SessionHistory?> getSessionHistory(String sessionId) async {
    try {
      final url = '$_baseUrl/api/sessions/$sessionId/history';
      logger.d('Getting session history: GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        logger.i('Retrieved session history successfully. Messages: ${data['history']?.length ?? 0}');
        return SessionHistory.fromJson(data);
      } else {
        logger.e('Failed to get session history (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      logger.e('Get session history network error: $e');
      return null;
    }
  }

  Future<String?> createNewSession({String? title}) async {
    try {
      final url = '$_baseUrl/api/sessions';
      final body = {
        'title': title,
      };
      
      logger.d('Creating new session: POST $url');
      logger.d('Request body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        logger.i('Session created successfully: ${data['session_id']}');
        return data['session_id'];
      } else {
        logger.e('Failed to create session (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      logger.e('Create session network error: $e');
      return null;
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    try {
      final url = '$_baseUrl/api/sessions/$sessionId';
      logger.d('Deleting session: DELETE $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        logger.i('Session deleted successfully: $sessionId');
        return true;
      } else {
        logger.e('Failed to delete session (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Delete session network error: $e');
      return false;
    }
  }

  Future<bool> updateSessionTitle(String sessionId, String title) async {
    try {
      final url = '$_baseUrl/api/sessions/$sessionId/title';
      final body = {
        'title': title,
      };
      
      logger.d('Updating session title: PUT $url');
      logger.d('Request body: ${json.encode(body)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        logger.i('Session title updated successfully: $sessionId -> $title');
        return true;
      } else {
        logger.e('Failed to update session title (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Update session title network error: $e');
      return false;
    }
  }
}

class ChatResult {
  final bool success;
  final String? sessionId;
  final String? response;
  final List<String>? sources;
  final String? error;

  ChatResult.success({
    this.sessionId,
    this.response,
    this.sources,
  }) : success = true, error = null;

  ChatResult.error(this.error)
      : success = false,
        sessionId = null,
        response = null,
        sources = null;
}

class ChatSession {
  final String id;
  final String title;
  final String createdAt;
  final String updatedAt;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      messageCount: json['message_count'] ?? 0,
    );
  }
}

class SessionHistory {
  final String sessionId;
  final List<ChatMessage> history;

  SessionHistory({
    required this.sessionId,
    required this.history,
  });

  factory SessionHistory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> historyData = json['history'] ?? [];
    final history = historyData.map((msg) => ChatMessage.fromJson(msg)).toList();
    
    return SessionHistory(
      sessionId: json['session_id'],
      history: history,
    );
  }
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderType;
  final String content;
  final Map<String, dynamic>? messageData;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderType,
    required this.content,
    this.messageData,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sessionId: json['session_id'],
      senderType: json['sender_type'],
      content: json['content'],
      messageData: json['message_data'],
      createdAt: json['created_at'],
    );
  }

  bool get isUser => senderType == 'user';
  bool get isBot => senderType == 'bot';
}
