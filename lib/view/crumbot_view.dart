import 'package:flutter/material.dart';

class ChatBotView extends StatefulWidget {
  @override
  _ChatBotViewState createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text.trim()});
      _messages.add({
        'sender': 'bot',
        'text': _generateBotResponse(text.trim()),
      });
      _controller.clear();
    });
  }

  String _generateBotResponse(String input) {
    // Simple response logic
    return "Thanks for sharing that. I'm here to listen.";
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser
              ? Color.fromARGB(255, 119, 137, 161)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(message['text'] ?? '', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E2DA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD3DBDD),
        elevation: 2,
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color.fromARGB(255, 238, 236, 232),
              backgroundImage: AssetImage('assets/images/robotHandFront.png'),
              radius: 18,
            ),
            const SizedBox(width: 10),
            const Text(
              'Crumbot',
              style: TextStyle(
                color: Color(0xFF011C45),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF011C45)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 245, 239, 229),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribí algo...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF3B4D65)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
