// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() {
    final user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  void _sendMessage() async {
    if (_user == null) {
      return;
    }

    await _firestore.collection('messages').add({
      'text': _messageController.text,
      'sender': _user!.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs.toList();
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message['text'];
                  var messageSender = message['sender'];

                  var messageWidget = MessageWidget(
                    sender: messageSender,
                    text: messageText,
                    isMe: _user?.email == messageSender,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                _sendMessage();
              }
            },
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  const MessageWidget({super.key, 
    required this.sender,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(sender[0]),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}