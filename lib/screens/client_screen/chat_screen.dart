import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! I am your NyayMarg legal assistant. How can I help you today?", "isBot": true},
  ];
  bool _isTyping = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({"text": text, "isBot": false});
      _isTyping = true;
    });
    _controller.clear();

    // Simulate AI response streaming
    _simulateResponse("I've analyzed your query about property disputes. I found 3 similar cases in the Bengaluru District Court with a 65% success rate for similar claims. Would you like to view the precedents or predict the case outcome?");
  }

  void _simulateResponse(String fullResponse) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final id = _messages.length;
    setState(() {
      _messages.add({"text": "", "isBot": true, "id": id});
      _isTyping = false;
    });

    String currentText = "";
    final words = fullResponse.split(" ");
    
    for (var word in words) {
      await Future.delayed(const Duration(milliseconds: 50));
      currentText += "$word ";
      if (mounted) {
        setState(() {
          _messages[id] = {"text": currentText.trim(), "isBot": true};
        });
      }
    }

    // Add Action Cards after response
    if (mounted) {
      setState(() {
        _messages.add({
          "isBot": true,
          "isCard": true,
          "actions": [
            {"label": "View Precedents", "icon": Icons.library_books},
            {"label": "Predict Case", "icon": Icons.analytics_outlined},
          ]
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Legal Assistant"),
        actions: [
          IconButton(icon: const Icon(Icons.history, color: Colors.white54), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildDisclaimer(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isCard'] == true) {
                  return _buildActionCard(msg['actions']);
                }
                return _buildChatBubble(msg['text'], msg['isBot']);
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      color: PremiumTheme.primaryGold.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Text(
        "⚠️ AI-generated responses are for guidance only.",
        style: TextStyle(color: Colors.white38, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isBot ? PremiumTheme.surfaceDark : PremiumTheme.primaryGold,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 0 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 0),
          ),
          border: isBot ? Border.all(color: Colors.white10) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? Colors.white.withValues(alpha: 0.9) : Colors.black,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildActionCard(List actions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 0),
      child: Row(
        children: actions.map<Widget>((action) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            backgroundColor: PremiumTheme.deepBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: PremiumTheme.primaryGold, width: 0.5),
            ),
            avatar: Icon(action['icon'], size: 16, color: PremiumTheme.primaryGold),
            label: Text(action['label'], style: const TextStyle(color: PremiumTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () {},
          ),
        )).toList(),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Row(
        children: [
          const Text("NyayMarg is thinking", style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: PremiumTheme.primaryGold,
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumTheme.deepBlue,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: PremiumTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type your legal query...",
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: PremiumTheme.primaryGold,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black, size: 20),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}