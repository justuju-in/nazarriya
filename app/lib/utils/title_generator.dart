class TitleGenerator {
  /// Generate a meaningful title from message content
  /// Takes the first 50 characters and truncates at word boundary
  static String generateTitle(String message) {
    if (message.isEmpty) {
      return "New Chat Session";
    }
    
    // Clean up the message - remove extra whitespace
    final cleanedMessage = message.trim();
    
    // If message is very short, use it as is
    if (cleanedMessage.length <= 50) {
      return cleanedMessage;
    }
    
    // Take first 50 characters and find the last complete word
    final truncated = cleanedMessage.substring(0, 50);
    final lastSpaceIndex = truncated.lastIndexOf(' ');
    
    // If no space found, use the truncated version as is
    if (lastSpaceIndex == -1) {
      return '$truncated...';
    }
    
    // Use the last complete word boundary
    final title = truncated.substring(0, lastSpaceIndex);
    return '$title...';
  }
  
  /// Generate a fallback title based on timestamp
  static String generateFallbackTitle() {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return 'Chat at $timeString';
  }
}
