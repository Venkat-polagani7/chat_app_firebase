import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late final User loggedInUser;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String chatID = 'chatScreen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController =
      TextEditingController(); //to provide initial value for text field
  final _auth = FirebaseAuth.instance;
  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {}
  }
  // getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     var messageData = message.data();
  //     print(messageData);
  //   }
  // }

  //helps in streaming of the  new messages
  // messagesStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       var messageData = message.data();
  //       print(messageData);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // messagesStream();
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      //style: TextStyle(color: Colors.black87),
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});

                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //turn snapshots of data into actual widgets when everytime new data comes through
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //docs gets the list of documents included in snapshot
          //data - contains all the data of the document copied from document snapshot
          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];

          for (var message in messages) {
            final Map<String, dynamic> messageData =
                message.data() as Map<String, dynamic>;
            final messageText = messageData['text'] as String;
            final messageSender = messageData['sender'] as String;

            final currentUser = loggedInUser.email;

            if (currentUser == messageSender) {
              //the message from logged in user.
            }

            final messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender);
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              //reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        } else {
          // If there's no data yet, return a placeholder or loading indicator
          return Container(
            height: 30.0,
            width: 40.0,
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              strokeWidth: 4.0,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {required this.sender, required this.text, required this.isMe});

  final String sender;
  final String text;
  final bool isMe; //for current user and new user. basically for two users.

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))
                  : BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 18.0,
                      color: isMe ? Colors.white : Colors.black54),
                ),
              )),
        ],
      ),
    );
  }
}
