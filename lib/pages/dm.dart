import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/block.dart';
import 'package:jam/pages/profile/profile_other.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/chat_media_utils.dart';
import 'package:jam/widgets/alert.dart';
import 'package:jam/widgets/chat_message_dm.dart';
import 'package:jam/widgets/profile_picture.dart';
import 'package:provider/provider.dart';

class DM extends StatefulWidget {
  // Constructor
  const DM({required this.otherUsername, required this.otherId}) : super();
  final String otherUsername;
  final String otherId;

  @override
  _DMState createState() =>
      _DMState(otherUsername: otherUsername, otherId: otherId);
}

class _DMState extends State<DM> with WidgetsBindingObserver {
  // Constructor
  _DMState({required this.otherUsername, required this.otherId}) : super();
  final String otherUsername;
  final String otherId;

  final chatTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    chatTextController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print("dm dispose");
  }

  @override
  void deactivate() {
    Provider.of<MessageProvider>(context, listen: false).exitDM(otherId);
    print("deactivate");
    super.deactivate();
  }

  @override
  void initState() {
    Provider.of<MessageProvider>(context, listen: false).enterDM(otherId);
    super.initState();
    print("dm init state");
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("dm resumed");
        Provider.of<MessageProvider>(context, listen: false).enterDM(otherId);
        break;
      case AppLifecycleState.inactive:
        print("dm inactive");
        break;
      case AppLifecycleState.paused:
        print("dm paused");
        Provider.of<MessageProvider>(context, listen: false).exitDM(otherId);
        break;
      case AppLifecycleState.detached:
        print("dm detached");
        Provider.of<MessageProvider>(context, listen: false).exitDM(otherId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    // for scrolling to bottom when new message arrives
    ScrollController _controller = ScrollController();
    bool firstBuild = true;

    Future<void> _animateToBottom() async {
      print("animate to bottom");
      _controller.animateTo(
        _controller.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    }

    void _send() {
      String message = chatTextController.text.trim();
      chatTextController.clear();
      if (message == "") return;
      sendMessage(otherId, message, MessageTypes.text);
    }

    TextButton blockButton = TextButton(
      child: Text("Block"),
      onPressed: () {
        Provider.of<MessageProvider>(context, listen: false).block(otherId);
        blockRequest(user.id!, user.token!, otherId);
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // return to list
      },
    );
    AlertDialog alertDialog = alert(
      "Do you really want to block $otherUsername?",
      blockButton,
      content:
          Text("You won't be able to receive messages from $otherUsername."),
    );

    void _handleThreeDotClick(String value) {
      switch (value) {
        case 'Block':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alertDialog;
            },
          );
          break;
        case 'Unblock':
          Provider.of<MessageProvider>(context, listen: false).unblock(otherId);
          unBlockRequest(user.id!, user.token!, otherId);
          Navigator.pop(context);
          break;
      }
    }

    Future boxOpening =
        Provider.of<MessageProvider>(context, listen: false).openBox(otherId);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.pinkAccent,
        title: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileOther(
                otherUsername: otherUsername,
                otherId: otherId,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                smallProfilePicture(otherId),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        otherUsername,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleThreeDotClick,
            itemBuilder: (BuildContext context) {
              Set<String> options =
                  Provider.of<MessageProvider>(context, listen: false)
                          .messages
                          .get(otherId)
                          .isBlocked
                      ? {"Unblock"}
                      : {"Block"};
              return options.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
              future: boxOpening,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    print("dm future builder waiting");
                    return Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    // Decrement unread messages with this user and scroll to bottom
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      print("post frame callback");
                      _controller.jumpTo(_controller.position.maxScrollExtent);
                      int unRead =
                          Provider.of<MessageProvider>(context, listen: false)
                              .messages
                              .get(otherId)
                              .unreadMessages;
                      Provider.of<UnreadMessageProvider>(context, listen: false)
                          .decUnreadCount(unRead);
                    });
                    return ValueListenableBuilder(
                        valueListenable: Hive.box<ChatMessage>(
                                chatBoxName(user.id!, otherId))
                            .listenable(),
                        builder: (context, Box<ChatMessage> box, widget) {
                          List<ChatMessage> messages =
                              box.values.toList().cast();
                          if (!firstBuild) {
                            // new message incoming or sent
                            _animateToBottom();
                          }
                          firstBuild = false;
                          return ListView.builder(
                            controller: _controller,
                            itemCount: messages.length,
                            //shrinkWrap: true,
                            padding: EdgeInsets.only(top: 10, bottom: 70),
                            //physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: (messages[index].isIncomingMessage
                                    ? EdgeInsets.only(
                                        left: 14,
                                        right: 60,
                                        top: 10,
                                        bottom: 10,
                                      )
                                    : EdgeInsets.only(
                                        left: 60,
                                        right: 14,
                                        top: 10,
                                        bottom: 10,
                                      )),
                                child: Align(
                                  alignment: (messages[index].isIncomingMessage
                                      ? Alignment.topLeft
                                      : Alignment.topRight),
                                  child: chatMessage(messages[index]),
                                ),
                              );
                            },
                          );
                        });
                }
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              padding: EdgeInsets.only(left: 20, bottom: 5, top: 5, right: 5),
              //height: 60,
              width: double.infinity,
              //color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Scrollbar(
                      child: TextField(
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 6,
                        onEditingComplete: () => _send(),
                        controller: chatTextController,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          Timer(
                              Duration(milliseconds: 200),
                              () => _controller.jumpTo(
                                  _controller.position.maxScrollExtent));
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (builder) => bottomSheet());
                    },
                    icon: Icon(Icons.attach_file),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: FloatingActionButton(
                      onPressed: () => _send(),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.pinkAccent,
                      elevation: 0,
                      mini: true,
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

  Widget bottomSheet() {
    return Container(
      height: 180,
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.camera_alt, Colors.pink, "Camera", _selectCamera),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                      Icons.insert_photo, Colors.purple, "Image", _selectImage),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(
      IconData icons, Color color, String text, void Function() onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Icon(icons),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(CircleBorder()),
            padding: MaterialStateProperty.all(EdgeInsets.all(20)),
            backgroundColor: MaterialStateProperty.all(color),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
          ),
        )
      ],
    );
  }

  final ImagePicker _picker = ImagePicker();

  void _selectImage() async {
    // select image from gallery
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    Navigator.pop(context);
    _sendImage(image);
  }

  void _selectCamera() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    );
    Navigator.pop(context);
    _sendImage(image);
  }

  Future _sendImage(XFile? image) async {
    if (image != null) {
      // compress the image
      Uint8List imageBytes = await File(image.path).readAsBytes();
      print(imageBytes.length);
      Uint8List compressed = await compressChatImage(imageBytes);
      print(compressed.length);
      // copy the compressed image into a separate folder
      String imgPath = await saveChatImage(compressed, user.id!);
      // give the path of image to sendMessage function
      sendMessage(otherId, imgPath, MessageTypes.picture, bytes: compressed);
    }
  }
}
