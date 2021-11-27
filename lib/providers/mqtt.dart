import 'package:jam/models/chat_message_model.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '/constants/app_url.dart';

var client;
var username;
var provider;

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

Future<MqttServerClient> connect(String _username, String password, MessageProvider msgProvider,
    UnreadMessageProvider unreadProvider) async {
  username = _username;
  await msgProvider.init(unreadProvider, username);
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

  var deviceId = await getDeviceIdentifier();
  print("deviceId: " + deviceId);

  _client.connectionMessage = MqttConnectMessage()
      .authenticateAs(username, password)
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      //.startClean()
      .withClientIdentifier('$username:$deviceId')
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

    print('Received message:$payload from topic: ${c[0].topic}>');

    var message = jsonDecode(payload);
    if (message == null) {
      return;
    }
    String date = message["timestamp"];
    int timestamp = DateTime.parse(date).millisecondsSinceEpoch;
    var username = message["from"];
    var messageContent = message["content"];
    msgProvider.add(
        username,
        ChatMessage(
          messageContent: messageContent,
          isIncomingMessage: true,
          timestamp: timestamp,
        ),
        unreadProvider);
  });

  client = _client;
  return _client;
}

void sendMessage(String receiver, String content) {
  final builder = MqttClientPayloadBuilder();
  String timestamp = DateTime.now().toUtc().toString();
  var message = {
    "from": username,
    "timestamp": timestamp,
    "content": content
  };
  builder.addUTF8String(jsonEncode(message));
  client.publishMessage("/$receiver/inbox", MqttQos.exactlyOnce, builder.payload);
}

/// connection succeeded
void onConnected() {
  print('Connected');
  // every user subscribes to topic named after them
  client.subscribe("/$username/inbox", MqttQos.exactlyOnce);
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
