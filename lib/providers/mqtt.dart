import 'package:jam/models/user.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/app_url.dart';

MqttServerClient? client;
late User user;
var provider;

var clientId;

Future<String> getDeviceIdentifier() async {
  String deviceIdentifier = "unknown";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceIdentifier = androidInfo.androidId!;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceIdentifier = iosInfo.identifierForVendor!;
  } else if (kIsWeb) {
    // The web doesnt have a device UID, so use a combination fingerprint as an example
    WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
    deviceIdentifier = webInfo.vendor! + webInfo.userAgent! + webInfo.hardwareConcurrency.toString();
  } else if (Platform.isLinux) {
    LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    deviceIdentifier = linuxInfo.machineId!;
  }
  return deviceIdentifier;
}

Future<MqttServerClient> connect(User _user, MessageProvider msgProvider,
    UnreadMessageProvider unreadProvider, context) async {
  user = _user;
  var username = user.username!;
  var password = user.token;
  await msgProvider.init(unreadProvider, user, context);
  provider = msgProvider;
  MqttServerClient _client =
      MqttServerClient.withPort(AppUrl.mqttURL, username, AppUrl.mqttPort);
  client = _client;
  _client.logging(on: true);
  _client.keepAlivePeriod = 60;
  _client.onConnected = onConnected;
  _client.onDisconnected = onDisconnected;
  _client.onUnsubscribed = onUnsubscribed;
  _client.onSubscribed = onSubscribed;
  _client.onSubscribeFail = onSubscribeFail;
  _client.pongCallback = pong;
  _client.autoReconnect = true;
  _client.secure = true;

  var deviceId = await getDeviceIdentifier();
  print("deviceId: " + deviceId);

  clientId = '${user.id}:$deviceId';

  _client.connectionMessage = MqttConnectMessage()
      .authenticateAs(user.id, password)
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      //.startClean()
      .withClientIdentifier(clientId)
      .withWillQos(MqttQos.exactlyOnce)
      .withProtocolVersion(4);

  try {
    await _client.connect();
  } catch (e) {
    print('Exception: $e');
    _client.disconnect();
  }

  _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage byteMessage = c[0].payload as MqttPublishMessage;
    final payload = MqttEncoding().decoder.convert(byteMessage.payload.message);

    var topic = c[0].topic;

    print('Received message:$payload from topic: $topic>');

    var message = jsonDecode(payload);
    if (message == null) {
      return;
    }

    if (topic == "/${user.id}/devices/$clientId") {
      // see mqtt error documentation for handling these errors.
      var type = message["type"];
      var handler = message["handler"];
      var category = message["category"];
      var message_descriptor = message["message"];
      var messageId = message["messageId"];
      // see line 139, if the messageId is some other value than null
      // there was an error sending that message, turn it to red.
    }
    else {
      String date = message["timestamp"];
      int timestamp = DateTime.parse(date).millisecondsSinceEpoch;
      var id = message["from"];
      var messageContent = message["content"];
      msgProvider.add(
          id,
          ChatMessage(
            messageContent: messageContent,
            isIncomingMessage: true,
            timestamp: timestamp,
            successful: true,
          ),
          unreadProvider);
    }
  });

  client = _client;
  return _client;
}

/// Returns true if message is sent successfully
bool sendMessage(String receiver, String content) {
  final builder = MqttClientPayloadBuilder();
  String timestamp = DateTime.now().toUtc().toString();
  var message = {
    "from": user.id,
    "timestamp": timestamp,
    "content": content,
  };
  builder.addUTF8String(jsonEncode(message));
  try {
    var messageId = client?.publishMessage("/$receiver/inbox", MqttQos.exactlyOnce, builder.payload!);
    // this message id should be stored for further error checks
  } catch (e) {
    print(e);
    return false;
  }
  return true;
}

Future disconnect() async {
  client?.disconnect();
}

/// connection succeeded
void onConnected() {
  print('Connected');
  // every user subscribes to topic for their id
  client?.subscribe("/${user.id}/inbox", MqttQos.exactlyOnce);
  client?.subscribe("/${user.id}/devices/$clientId", MqttQos.atMostOnce);
}

/// unconnected
void onDisconnected() {
  print('Disconnected');
  //connect(username, provider);
}

/// subscribe to topic succeeded
void onSubscribed(String topic) {
  print('Subscribed topic: $topic');
}

/// subscribe to topic failed
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}

/// unsubscribe succeeded
void onUnsubscribed(String? topic) {
  print('Unsubscribed topic: $topic');
}

/// PING response received
void pong() {
  print('Ping response client callback invoked');
}
