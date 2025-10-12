import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String namaTeknisi;
  final String? fotoTeknisi;

  const ChatPage({super.key, required this.namaTeknisi,this.fotoTeknisi,});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isOnline = true;

  // 🔹 Load pesan dari penyimpanan lokal
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "chat_${widget.namaTeknisi}";
    final savedData = prefs.getString(key);
    if (savedData != null) {
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(savedData));
      setState(() {
        _messages.addAll(decoded);
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "chat_${widget.namaTeknisi}";
    await prefs.setString(key, jsonEncode(_messages));
  }

  // 🔹 Kirim pesan
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final msg = {
      "text": text.trim(),
      "isUser": true,
      "time": DateFormat('HH:mm').format(DateTime.now()),
    };

    setState(() {
      _messages.add(msg);
    });
    _controller.clear();
    _scrollToBottom();
    _saveMessages();

    // 🔹 Simulasi balasan teknisi
    Future.delayed(const Duration(seconds: 1), () {
      final reply = {
        "text": "Baik, saya akan segera membantu Anda 😊",
        "isUser": false,
        "time": DateFormat('HH:mm').format(DateTime.now()),
      };
      setState(() {
        _messages.add(reply);
      });
      _scrollToBottom();
      _saveMessages();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🔹 Hapus semua pesan
  void _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "chat_${widget.namaTeknisi}";
    await prefs.remove(key);
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4381),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://i.pinimg.com/736x/36/42/f6/3642f64179d8be4b9ef4b9a89cf29010.jpg"),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.namaTeknisi,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isOnline ? "Online" : "Offline",
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Hapus Riwayat Chat",
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Daftar pesan
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isUser = message["isUser"] as bool;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF0C4381)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message["text"],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message["time"],
                          style: TextStyle(
                            color: isUser ? Colors.white70 : Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input pesan
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: "Ketik pesan...",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C4381),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
