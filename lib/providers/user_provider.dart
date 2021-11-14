import 'package:flutter/foundation.dart';
import 'package:jam/providers/mqtt.dart' as mqttWrapper;
import 'package:provider/provider.dart';
import '/domain/user.dart';
import 'message_provider.dart';

class UserProvider with ChangeNotifier {
  User? _user = new User();

  User? get user => _user;

  void setUser(User? user, context) {
    mqttWrapper.connect(user!.email!, Provider.of<MessageProvider>(context, listen: false));
    _user = user;
    // notifyListeners();
  }
}
