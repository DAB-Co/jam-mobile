import 'package:hive_flutter/hive_flutter.dart';

Future openStringHiveBox(String boxName) async {
  if (!Hive.isBoxOpen(boxName)) {
    await Hive.openBox<String>(boxName);
  }
}
