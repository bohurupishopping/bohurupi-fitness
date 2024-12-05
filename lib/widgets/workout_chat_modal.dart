import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../services/workout_chat_service.dart';
import '../models/workout.dart';

class WorkoutChatModal extends StatefulWidget {
  final String workoutName;
  final Workout workout;

  const WorkoutChatModal({
    Key? key,
    required this.workoutName,
    required this.workout,
  }) : super(key: key);

  @override
  State<WorkoutChatModal> createState() => _WorkoutChatModalState();
}

class _WorkoutChatModalState extends State<WorkoutChatModal> {
  final TextEditingController _messageController = TextEditingController();
  final WorkoutChatService _chatService = WorkoutChatService();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final List<String> _quickQuestions = [
    'এই এক্সারসাইজটি কীভাবে সঠিকভাবে করবেন?',
    'কোন মাংসপেশীগুলি কাজ করে?',
    'সাধারণ ভুলগুলি কী কী?',
    'নতুনদের জন্য টিপস?',
    'এই এক্সারসাইজে উন্নতি করবেন কীভাবে?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isUser': 'true',
      });
      _isLoading = true;
      _messageController.clear();
    });

    try {
      final response = await _chatService.getChatResponse(
        message,
        widget.workout,
      );

      setState(() {
        _messages.add({
          'text': response,
          'isUser': 'false',
        });
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Glass background
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF2D3142).withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Trainer Chat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            Text(
                              widget.workoutName,
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF2D3142).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          color: const Color(0xFF2D3142),
                        ),
                      ],
                    ),
                  ),
                  // Chat messages area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Quick action buttons
                          if (_messages.isEmpty) ...[
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _quickQuestions.map((question) => 
                                GestureDetector(
                                  onTap: () {
                                    _messageController.text = question;
                                    _sendMessage();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      question,
                                      style: const TextStyle(
                                        color: Color(0xFF4ECDC4),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ).animate().scale(
                                  delay: Duration(milliseconds: _quickQuestions.indexOf(question) * 100),
                                ),
                              ).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // Messages list
                          Expanded(
                            child: _messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.psychology_outlined,
                                        size: 48,
                                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                      ).animate(onPlay: (controller) => controller.repeat())
                                        .scaleXY(
                                          duration: 2.seconds,
                                          begin: 0.9,
                                          end: 1.1,
                                          curve: Curves.easeInOut,
                                        )
                                        .then()
                                        .scaleXY(
                                          duration: 2.seconds,
                                          begin: 1.1,
                                          end: 0.9,
                                          curve: Curves.easeInOut,
                                        ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Choose a question or ask anything\nabout this workout!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF2D3142).withOpacity(0.6),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 20),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message = _messages[index];
                                    final isUser = message['isUser'] == 'true';
                                    final text = message['text']!;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        mainAxisAlignment: isUser 
                                          ? MainAxisAlignment.end 
                                          : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (!isUser) ...[
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.psychology,
                                                color: Color(0xFF4ECDC4),
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isUser 
                                                  ? const Color(0xFF4ECDC4).withOpacity(0.1)
                                                  : Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: isUser
                                                    ? Colors.transparent
                                                    : Colors.black.withOpacity(0.1),
                                                ),
                                              ),
                                              child: Text(
                                                _formatMessage(text, isUser),
                                                style: TextStyle(
                                                  color: const Color(0xFF2D3142),
                                                  fontSize: 14,
                                                  height: 1.6,
                                                  fontFamily: 'Noto Sans Bengali',
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isUser)
                                            const SizedBox(width: 32),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chat input
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Ask anything about this workout...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Color(0xFF9A9CB8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF4ECDC4),
                                const Color(0xFF45B7D1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _sendMessage,
                            icon: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Floating AI Icon at the top
        Positioned(
          top: -30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4ECDC4),
                    const Color(0xFF45B7D1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
            ).animate()
              .scale(
                duration: 400.ms,
                curve: Curves.easeOut,
              )
              .slideY(
                begin: -1,
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
          ),
        ),
      ],
    );
  }

  String _formatMessage(String text, bool isUser) {
    if (isUser) return text;
    
    // Format AI response with proper styling
    String formattedText = text
      .replaceAll('**', '') // Remove markdown bold syntax
      .replaceAll('•', '\n•') // Add line break before bullets
      .replaceAll('\n\n', '\n') // Remove extra line breaks
      .trim();

    // Split into paragraphs
    final paragraphs = formattedText.split('\n');
    
    return paragraphs.map((paragraph) {
      // Add proper indentation for bullet points
      if (paragraph.startsWith('•')) {
        return '  $paragraph';
      }
      // Add spacing between paragraphs
      return '$paragraph\n';
    }).join('');
  }
} 