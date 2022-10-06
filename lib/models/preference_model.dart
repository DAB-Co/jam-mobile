import 'package:hive/hive.dart';

part "preference_model.g.dart";

@HiveType(typeId: 3)
class Preference {
  @HiveField(0)
  String name;
  @HiveField(1)
  String type;

  Preference(
      {required this.name, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Preference &&
              runtimeType == other.runtimeType &&
              name == other.name && type == other.type;

  @override
  int get hashCode => name.hashCode+type.hashCode;
}
