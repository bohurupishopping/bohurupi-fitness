import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_chat_service.dart';

class WorkoutChatModal extends StatefulWidget {
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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late final WorkoutChatService _chatService;

  // Pre-defined quick questions based on workout context
  final List<String> _quickQuestions = [
    "How do I do this correctly?",
    "What muscles does this work?",
    "Common mistakes to avoid?",
    "Breathing technique?",
    "Modifications for beginners?",
  ];

  @override
  void initState() {
    super.initState();
    _chatService = WorkoutChatService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': 'true'});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _chatService.getChatResponse(text, widget.workout);

      if (mounted) {
        setState(() {
          _messages.add({'text': response, 'isUser': 'false'});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': 'Sorry, I encountered an error. Please try again.',
            'isUser': 'false',
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
              controller: _controller,
              isLoading: _isLoading,
              onSend: () => _sendMessage(_controller.text),
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                workoutName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 20),
            color: Theme.of(context).iconTheme.color,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      spacing: 8,
      runSpacing: 8,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          question,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: 40,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a question or ask anything\nabout this workout!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4, fontSize: 14),
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
      padding: const EdgeInsets.only(top: 16, bottom: 16),
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isUser
            ? Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUser
                      ? Icons.person_outline_rounded
                      : Icons.psychology_rounded,
                  size: 16,
                  color: isUser
                      ? Theme.of(context).primaryColor
                      : const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isUser ? 'You' : 'AI Trainer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUser
                      ? Theme.of(context).primaryColor
                      : const Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isUser
              ? Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                    height: 1.5,
                  ),
                )
              : _buildFormattedMessage(context, text),
        ],
      ),
    );
  }

  Widget _buildFormattedMessage(BuildContext context, String text) {
    final List<InlineSpan> spans = [];
    final lines = text.split('\n');
    final normalStyle = TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
      fontSize: 14,
      height: 1.6,
    );
    final boldStyle = normalStyle.copyWith(fontWeight: FontWeight.bold);
    final headerStyle = normalStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.4,
    );

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) {
        if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Handle Headers (###)
      if (line.startsWith('###')) {
        spans.add(
          TextSpan(
            text: '${line.replaceAll('#', '').trim()}\n',
            style: headerStyle,
          ),
        );
        continue;
      }

      // Handle Bullet points
      if (line.startsWith('* ') || line.startsWith('- ')) {
        line = '• ${line.substring(2)}';
      }

      // Parse Bold (**text**)
      final parts = line.split('**');
      for (int j = 0; j < parts.length; j++) {
        if (j % 2 == 1) {
          // Bold part
          spans.add(TextSpan(text: parts[j], style: boldStyle));
        } else {
          // Normal part
          spans.add(TextSpan(text: parts[j], style: normalStyle));
        }
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(text: TextSpan(children: spans));
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.send_rounded, size: 20),
        color: Colors.white,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
