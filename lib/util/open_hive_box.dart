import 'package:hive_flutter/hive_flutter.dart';

Future openHiveBox(String boxName) async {
  if (!Hive.isBoxOpen(boxName)) {
    await Hive.openBox<String>(boxName);
  }
}
