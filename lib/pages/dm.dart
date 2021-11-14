import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:provider/provider.dart';

class DM extends StatefulWidget {
  // Constructor
  const DM({required this.otherUsername}) : super();
  final String otherUsername;

  @override
  _DMState createState() => _DMState(other: otherUsername);
}

class _DMState extends State<DM> {
  // Constructor
  _DMState({required this.other}) : super();
  final String other;

  final chatTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    chatTextController.dispose();
    super.dispose();
  }


  @override
  void activate() {
    Provider.of<MessageProvider>(context, listen: false).messagesRead(other);
    Provider.of<MessageProvider>(context).enterDM(other);
    super.activate();
  }

  @override
  void deactivate() {
    Provider.of<MessageProvider>(context).exitDM(other);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.pinkAccent,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage("assets/avatar.png"),
              maxRadius: 20,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    other,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Online",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          ValueListenableBuilder(
              valueListenable: Hive.box<ChatMessage>(other).listenable(),
              builder: (context, Box<ChatMessage> box, widget) {
                List<ChatMessage> messages = box.values.toList().cast();
                return ListView.builder(
                  itemCount: messages.length,
                  //shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10, bottom: 70),
                  //physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment: (messages[index].isIncomingMessage
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (messages[index].isIncomingMessage
                                ? Colors.grey.shade200
                                : Colors.blue[200]),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            messages[index].messageContent,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              padding: EdgeInsets.only(left: 20, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              //color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: chatTextController,
                      decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      String message = chatTextController.text;
                      if (message != "") {
                        chatTextController.clear();
                        Provider.of<MessageProvider>(context, listen: false)
                            .add(other, ChatMessage(
                          messageContent: message,
                          isIncomingMessage: false,
                          timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
                        ));
                        sendMessage(other, message);
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.pinkAccent,
                    elevation: 0,
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
