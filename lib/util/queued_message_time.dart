import 'package:hive_flutter/hive_flutter.dart';

Future<Box<bool>> _getQueuedBox() async {
  final String queuedBoxName = "queued";
  if (!Hive.isBoxOpen(queuedBoxName)) {
    await Hive.openBox<bool>(queuedBoxName);
  }
  return Hive.box<bool>(queuedBoxName);
}

Future addToQueuedBox(String id) async {
  Box<bool> q = await _getQueuedBox();
  q.put(id, true);
}

/// Returns true if this user messaged earlier,
/// also deletes that data after 3 seconds
Future<bool> isOldMessage(String id) async {
  Box<bool> q = await _getQueuedBox();
  bool result = q.get(id) ?? false;
  // no new notification for 5 seconds
  Future.delayed(const Duration(seconds: 3), () {
    q.delete(id);
  });
  return result;
}
