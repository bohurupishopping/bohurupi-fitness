import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/workout_chat_service.dart';
import '../models/workout.dart';

class WorkoutChatModal extends StatefulWidget {
  static const double _modalHeight = 0.75;
  static const Duration _animationDuration = Duration(milliseconds: 200);

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
      _messages.add({'text': message, 'isUser': 'true'});
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _chatService.getChatResponse(
        message,
        widget.workout,
      );
      if (mounted) {
        setState(() {
          _messages.add({'text': response, 'isUser': 'false'});
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
        const Positioned(top: -36, left: 0, right: 0, child: _FloatingAIIcon()),
      ],
    );
  }

  Widget _buildModalContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height:
              MediaQuery.of(context).size.height *
              WorkoutChatModal._modalHeight,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
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

  const _ChatHeader({required this.workoutName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Trainer Chat',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                workoutName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: Theme.of(context).iconTheme.color,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              padding: const EdgeInsets.all(8),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (messages.isEmpty) ...[
            const SizedBox(height: 24),
            _QuickQuestions(questions: quickQuestions, onTap: onQuestionTap),
            const SizedBox(height: 24),
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

  const _QuickQuestions({required this.questions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: questions
          .map(
            (question) => _QuickQuestionButton(
              question: question,
              onTap: () => onTap(question),
            ),
          )
          .toList(),
    );
  }
}

class _QuickQuestionButton extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _QuickQuestionButton({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          question,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: 48,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose a question or ask anything\nabout this workout!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<Map<String, String>> messages;
  final ScrollController scrollController;

  const _MessagesList({required this.messages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['isUser'] == 'true';
        return _ChatMessage(text: message['text']!, isUser: isUser);
      },
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 24),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Text(
                _formatMessage(text, isUser),
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
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

    return paragraphs
        .map((paragraph) {
          if (paragraph.startsWith('•')) {
            return '  $paragraph';
          }
          return '$paragraph\n';
        })
        .join('');
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SendButton(isLoading: isLoading, onPressed: onSend),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.all(12),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: const Icon(
          Icons.psychology_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
