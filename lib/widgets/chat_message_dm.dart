import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:jam/widgets/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

Container chatMessage(ChatMessage msg) {
  if (msg.type == MessageTypes.picture.index) {
    return Container(
      height: 400,
      width: 400,
      decoration: BoxDecoration(
        border:
            Border.all(color: msg.successful ? Colors.transparent : Colors.red),
        image: DecorationImage(
          fit: BoxFit.contain,
          image: (FileImage(File(msg.messageContent))),
        ),
      ),
    );
  } else if (msg.type == MessageTypes.video.index) {
    return Container(
      child: CustomVideoPlayer(videoPath: msg.messageContent),
      decoration: BoxDecoration(
        border:
            Border.all(color: msg.successful ? Colors.transparent : Colors.red),
      ),
    );
  } else {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            (msg.isIncomingMessage ? Colors.grey.shade200 : Colors.blue[200]),
      ),
      padding: EdgeInsets.all(16),
      child: SelectableLinkify(
        text: msg.messageContent,
        style: TextStyle(
          fontSize: 15,
          color: msg.successful ? Colors.black : Colors.red,
        ),
        onOpen: _onOpen,
        options: LinkifyOptions(looseUrl: true),
      ),
    );
  }
}

Future<void> _onOpen(LinkableElement link) async {
  if (await canLaunch(link.url)) {
    await launch(link.url);
  } else {
    throw 'Could not launch $link';
  }
}
