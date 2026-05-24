import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final List<Map<String, String>> _messages = [
    {
      "sender": "bot",
      "text": "Hello! I am your SmartBus Assistant. How can I help you today?"
    }
  ];

  final List<String> _quickQuestions = [
    "How to book a ticket?",
    "How to cancel a ticket?",
    "Refund status/policy",
    "How much time for refund?"
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  void _handleMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _messageController.clear();
      
      String response = "";
      String query = text.toLowerCase();

      if (query.contains("book") || query.contains("how to book")) {
        response = "To book a ticket: \n1. Go to Home\n2. Click 'Book Your Bus'\n3. Select Districts and Date\n4. Choose a bus and pick your seats\n5. Pay to confirm!";
      } else if (query.contains("cancel")) {
        response = "To cancel: \nGo to 'My Tickets', select your ticket, and click the 'Cancel' button. Note: You must cancel at least 2 hours before departure.";
      } else if (query.contains("refund") && (query.contains("policy") || query.contains("status"))) {
        response = "Refund Policy: \n- 100% refund if cancelled 24hrs before.\n- 80% refund if cancelled 12hrs before.\n- No refund if cancelled within 2 hours.";
      } else if (query.contains("time") && query.contains("refund")) {
        response = "Refunds are usually processed within 3-5 business days directly to your original payment method.";
      } else if (query.contains("hello") || query.contains("hi")) {
        response = "Hi there! I'm here to help you with your bus bookings. What can I do for you?";
      } else {
        response = "I've received your message. Let me connect you with a live agent for more specific help, or try one of the quick questions below.";
      }
      
      // Artificial delay for realism
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _messages.add({"sender": "bot", "text": response});
          });
          _scrollToBottom();
        }
      });
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Chat Support"),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isBot = msg["sender"] == "bot";
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[200] : AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(15).copyWith(
                        bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(15),
                        bottomRight: isBot ? const Radius.circular(15) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(color: isBot ? Colors.black : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Quick Questions Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(_quickQuestions[index]),
                    onPressed: () => _handleMessage(_quickQuestions[index]),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(color: AppConstants.primaryColor, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 10),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: _handleMessage,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _messageController.clear(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppConstants.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _handleMessage(_messageController.text),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
