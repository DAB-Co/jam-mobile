import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '/constants/app_url.dart';

var client;
var username;

Future<MqttServerClient> connect(String _username) async {
  username = _username;
  MqttServerClient _client =
      MqttServerClient.withPort(AppUrl.mqttURL, _username, AppUrl.mqttPort);
  client = _client;
  _client.logging(on: true);
  _client.keepAlivePeriod = 60;
  _client.onConnected = onConnected;
  _client.onDisconnected = onDisconnected;
  _client.onUnsubscribed = onUnsubscribed;
  _client.onSubscribed = onSubscribed;
  _client.onSubscribeFail = onSubscribeFail;
  _client.pongCallback = pong;

  _client.connectionMessage = MqttConnectMessage()
      //.authenticateAs('username', 'password')
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      //.startClean()
      .withWillQos(MqttQos.atLeastOnce);

  try {
    await _client.connect();
  } catch (e) {
    print('Exception: $e');
    _client.disconnect();
  }

  _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);

    print('Received message:$payload from topic: ${c[0].topic}>');
  });

  client = _client;
  return _client;
}

void sendMessage(String receiver, String message) {
  final builder = MqttClientPayloadBuilder();
  builder.addString("$username: $message");
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
