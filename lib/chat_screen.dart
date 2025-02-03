import 'dart:collection';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];
 List<ChatUser> typingChatUsers=[];
  ChatUser currentUser = ChatUser(id: '1', firstName: 'Zulqarnain');
  ChatUser geminiUser = ChatUser(
      id: '2',
      firstName: 'Gemini',
      profileImage:"https://www.google.com/url?sa=i&url=https%3A%2F%2Fuxwing.com%2Fgoogle-gemini-icon%2F&psig=AOvVaw0swk6zthHmADfAU0zsdJRR&ust=1721380223615000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCKDwm5mfsIcDFQAAAAAdAAAAABAE");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Gemini Chat Bot",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
          ),
        ),
        body: DashChat(
          typingUsers: [geminiUser],
           inputOptions: const InputOptions(
              alwaysShowSend: true,
            ),
            currentUser: currentUser,
            onSend: _sendMessage,
            messages: messages));
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
      typingChatUsers.add(geminiUser);
    });
    try {
      String question = chatMessage.text;
      gemini.streamGenerateContent(question).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content!.parts!.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;

        } else {
          String response = event.content!.parts!.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: response);
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      typingChatUsers.remove(geminiUser);
    });
  }
}
