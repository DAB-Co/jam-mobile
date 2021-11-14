import 'package:jam/models/chat_message_model.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '/constants/app_url.dart';

var client;
var username;
var provider;

Future<MqttServerClient> connect(String _username, MessageProvider msgProvider,
    UnreadMessageProvider unreadProvider) async {
  username = _username;
  await msgProvider.init(unreadProvider);
  provider = msgProvider;
  MqttServerClient _client =
      MqttServerClient.withPort(AppUrl.mqttURL, username, AppUrl.mqttPort);
  client = _client;
  _client.logging(on: true);
  //_client.keepAlivePeriod = 60;
  _client.onConnected = onConnected;
  _client.onDisconnected = onDisconnected;
  _client.onUnsubscribed = onUnsubscribed;
  _client.onSubscribed = onSubscribed;
  _client.onSubscribeFail = onSubscribeFail;
  _client.pongCallback = pong;

  _client.connectionMessage = MqttConnectMessage()
      //.authenticateAs('username', 'password')
      //.withWillTopic('willtopic')
      //.withWillMessage('Will message')
      //.startClean()
      .withClientIdentifier(username)
      .withWillQos(MqttQos.atMostOnce);

  try {
    await _client.connect();
  } catch (e) {
    print('Exception: $e');
    _client.disconnect();
  }

  RegExp messageRegex = new RegExp(r'(.+), (.+): (.+)');

  _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage byteMessage = c[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(byteMessage.payload.message);

    print('Received message:$payload from topic: ${c[0].topic}>');

    var match = messageRegex.firstMatch(payload);
    if (match == null) return;
    String date = match.group(1)!;
    int timestamp = DateTime.parse(date).millisecondsSinceEpoch;
    var username = match.group(2)!;
    var messageContent = match.group(3)!;
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

void sendMessage(String receiver, String message) {
  final builder = MqttClientPayloadBuilder();
  String timestamp = DateTime.now().toUtc().toString();
  builder.addString("$timestamp, $username: $message");
  client.publishMessage(receiver, MqttQos.atLeastOnce, builder.payload);
}

/// connection succeeded
void onConnected() {
  print('Connected');
  // every user subscribes to topic named after them
  client.subscribe(username, MqttQos.atLeastOnce);
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
