import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/workout_chat_service.dart';
import '../models/workout.dart';

class WorkoutChatModal extends StatefulWidget {
  static const double _modalHeight = 0.7;
  static const Duration _animationDuration = Duration(milliseconds: 150);
  static const Color _primaryColor = Color(0xFF4ECDC4);
  static const Color _secondaryColor = Color(0xFF45B7D1);
  static const Color _textColor = Color(0xFF2D3142);
  
  final String workoutName;
  final Workout workout;

  const WorkoutChatModal({
    super.key,
    required this.workoutName,
    required this.workout,
  });

  @override
  State<WorkoutChatModal> createState() => _WorkoutChatModalState();
}

class _WorkoutChatModalState extends State<WorkoutChatModal> {
  static const List<String> _quickQuestions = [
    'এই এক্সারসাইজটি কীভাবে সঠিকভাবে করবেন?',
    'কোন মাংসপেশীগুলি কাজ করে?',
    'সাধারণ ভুলগুলি কী কী?',
    'নতুনদের জন্য টিপস?',
    'এই এক্সারসাইজে উন্নতি করবেন কীভাবে?',
  ];

  final TextEditingController _messageController = TextEditingController();
  final WorkoutChatService _chatService = WorkoutChatService();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? predefinedMessage]) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isUser': 'true',
      });
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _chatService.getChatResponse(message, widget.workout);
      if (mounted) {
        setState(() {
          _messages.add({
            'text': response,
            'isUser': 'false',
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: WorkoutChatModal._animationDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildModalContent(),
        const Positioned(
          top: -30,
          left: 0,
          right: 0,
          child: _FloatingAIIcon(),
        ),
      ],
    );
  }

  Widget _buildModalContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * WorkoutChatModal._modalHeight,
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
              _ChatHeader(
                workoutName: widget.workoutName,
                onClose: () => Navigator.pop(context),
              ),
              Expanded(
                child: _ChatBody(
                  messages: _messages,
                  quickQuestions: _quickQuestions,
                  scrollController: _scrollController,
                  onQuestionTap: _sendMessage,
                ),
              ),
              _ChatInput(
                controller: _messageController,
                isLoading: _isLoading,
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String workoutName;
  final VoidCallback onClose;

  const _ChatHeader({
    required this.workoutName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: WorkoutChatModal._textColor.withOpacity(0.1),
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
                  color: WorkoutChatModal._textColor,
                ),
              ),
              Text(
                workoutName,
                style: TextStyle(
                  fontSize: 12,
                  color: WorkoutChatModal._textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: WorkoutChatModal._textColor,
          ),
        ],
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  final List<Map<String, String>> messages;
  final List<String> quickQuestions;
  final ScrollController scrollController;
  final Function(String) onQuestionTap;

  const _ChatBody({
    required this.messages,
    required this.quickQuestions,
    required this.scrollController,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (messages.isEmpty) ...[
            const SizedBox(height: 20),
            _QuickQuestions(
              questions: quickQuestions,
              onTap: onQuestionTap,
            ),
            const SizedBox(height: 20),
          ],
          Expanded(
            child: messages.isEmpty
                ? const _EmptyChat()
                : _MessagesList(
                    messages: messages,
                    scrollController: scrollController,
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickQuestions extends StatelessWidget {
  final List<String> questions;
  final Function(String) onTap;

  const _QuickQuestions({
    required this.questions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: questions.map((question) => 
        _QuickQuestionButton(
          question: question,
          onTap: () => onTap(question),
        ),
      ).toList(),
    );
  }
}

class _QuickQuestionButton extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _QuickQuestionButton({
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: WorkoutChatModal._primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: WorkoutChatModal._primaryColor.withOpacity(0.2),
          ),
        ),
        child: Text(
          question,
          style: const TextStyle(
            color: WorkoutChatModal._primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 48,
            color: WorkoutChatModal._primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a question or ask anything\nabout this workout!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WorkoutChatModal._textColor.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<Map<String, String>> messages;
  final ScrollController scrollController;

  const _MessagesList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['isUser'] == 'true';
        return _ChatMessage(
          text: message['text']!,
          isUser: isUser,
        );
      },
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WorkoutChatModal._primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: WorkoutChatModal._primaryColor,
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
                  ? WorkoutChatModal._primaryColor.withOpacity(0.1)
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
                style: const TextStyle(
                  color: WorkoutChatModal._textColor,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (isUser)
            const SizedBox(width: 32),
        ],
      ),
    );
  }

  String _formatMessage(String text, bool isUser) {
    if (isUser) return text;
    
    String formattedText = text
      .replaceAll('**', '')
      .replaceAll('•', '\n•')
      .replaceAll('\n\n', '\n')
      .trim();

    final paragraphs = formattedText.split('\n');
    
    return paragraphs.map((paragraph) {
      if (paragraph.startsWith('•')) {
        return '  $paragraph';
      }
      return '$paragraph\n';
    }).join('');
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function() onSend;

  const _ChatInput({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                controller: controller,
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
          _SendButton(
            isLoading: isLoading,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WorkoutChatModal._primaryColor,
            WorkoutChatModal._secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: WorkoutChatModal._primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
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
    );
  }
}

class _FloatingAIIcon extends StatelessWidget {
  const _FloatingAIIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              WorkoutChatModal._primaryColor,
              WorkoutChatModal._secondaryColor,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: WorkoutChatModal._primaryColor.withOpacity(0.3),
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
      ),
    );
  }
} 