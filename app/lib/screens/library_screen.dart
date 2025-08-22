import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Sample content data - in future this will come from backend
  final List<ContentItem> _contentItems = [
    ContentItem(
      title: 'Understanding Consent',
      description: 'Learn about the importance of consent in all relationships',
      type: ContentType.text,
      content: 'Consent is a clear, voluntary agreement between people to engage in specific sexual activity. It must be ongoing and can be withdrawn at any time.',
      imageUrl: null,
    ),
    ContentItem(
      title: 'Healthy Masculinity',
      description: 'Exploring positive expressions of masculinity',
      type: ContentType.text,
      content: 'Healthy masculinity involves emotional intelligence, respect for others, and rejecting harmful stereotypes. It\'s about being authentic to yourself while treating everyone with dignity.',
      imageUrl: null,
    ),
    ContentItem(
      title: 'Empathy Building',
      description: 'Developing emotional understanding and compassion',
      type: ContentType.text,
      content: 'Empathy is the ability to understand and share the feelings of others. It\'s a crucial skill for building meaningful relationships and creating a more compassionate world.',
      imageUrl: null,
    ),
    ContentItem(
      title: 'Gender Equality',
      description: 'Working towards a more equitable society',
      type: ContentType.text,
      content: 'Gender equality means that all people, regardless of gender, have equal rights, responsibilities, and opportunities. It\'s essential for a just and peaceful society.',
      imageUrl: null,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Library'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Educational Resources',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF6B46C1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore our collection of articles, videos, and resources designed to help you learn and grow.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Content Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _contentItems.length,
              itemBuilder: (context, index) {
                return _buildContentCard(_contentItems[index]);
              },
            ),
          ),
          
          // Page Indicator
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _contentItems.length,
                (index) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF6B46C1)
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
          
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage > 0
                        ? const Color(0xFF6B46C1)
                        : Colors.grey[300],
                    foregroundColor: _currentPage > 0
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: _currentPage < _contentItems.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage < _contentItems.length - 1
                        ? const Color(0xFF6B46C1)
                        : Colors.grey[300],
                    foregroundColor: _currentPage < _contentItems.length - 1
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(ContentItem item) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Content Type Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _getIconForType(item.type),
              size: 40,
              color: const Color(0xFF6B46C1),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF6B46C1),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              item.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Button
          ElevatedButton.icon(
            onPressed: () {
              // In future, this will open detailed view or play video
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${item.title}...'),
                  backgroundColor: const Color(0xFF6B46C1),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Learn More'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(ContentType type) {
    switch (type) {
      case ContentType.text:
        return Icons.article;
      case ContentType.image:
        return Icons.image;
      case ContentType.video:
        return Icons.video_library;
      case ContentType.audio:
        return Icons.audiotrack;
    }
  }
}

enum ContentType { text, image, video, audio }

class ContentItem {
  final String title;
  final String description;
  final ContentType type;
  final String content;
  final String? imageUrl;

  ContentItem({
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    this.imageUrl,
  });
}
