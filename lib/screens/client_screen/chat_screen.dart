import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // FIXED: Official package
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nyaya_marg/auth_screens/service/gemini_service.dart';
import 'package:nyaya_marg/screens/client_screen/home_screen.dart';
import 'package:nyaya_marg/theme/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your AI Legal Assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  bool _isTyping = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    final prompt = """
You are Nyaya Marg AI, a professional legal assistant for Indian law.
Answer **in English only**, keep it concise (3-5 sentences), cite sections.
Use **markdown** for bold: **Section 138**.
User query: "$text"
""";

    try {
      final aiReply = await GeminiService.generate(prompt);
      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          text: aiReply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, the AI is having trouble. Try again!",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.shadowGrey.withOpacity(0.15),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.deepBlue,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Legal Assistant',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Online',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false, // LEFT ALIGNED
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length && _isTyping) {
                  return _typingIndicator();
                }
                return _messageBubble(_messages[i]);
              },
            ),
          ),
          // INPUT BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowGrey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask anything about your legal rights...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.deepBlue,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MESSAGE BUBBLE
  Widget _messageBubble(ChatMessage msg) {
    final bool isUser = msg.isUser;
    final Color bubble = isUser
        ? AppColors.deepBlue
        : AppColors.lightBlue.withOpacity(0.9);
    final CrossAxisAlignment align =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubble,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight:
                    isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isUser
                ? Text(
                    msg.text,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  )
                : MarkdownBody(
                    data: msg.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      strong: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('h:mm a').format(msg.timestamp),
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  // TYPING INDICATOR
  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.goldenAccent,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _dot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.deepBlue,
        shape: BoxShape.circle,
      ),
    );
  }
}

// MODEL
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