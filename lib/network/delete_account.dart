import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/show_snackbar.dart';

import '../main.dart';

/// Delete Account Call, returns answer from server,
/// null if could not connect
Future<String?> deleteAccountCall(String userId, String password) async {
  final Map<String, dynamic> dataToSend = {
    "user_id": userId,
    "password": password,
  };
  try {
    var response = await post(
      Uri.parse(AppUrl.deleteAccount),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(dataToSend),
    );
    if (response.body == "Wrong api token") {
      print("wrong api token in delete account call");
      logout();
      showSnackBar(navigatorKey.currentContext!, "Wrong api token");
    }
    return response.body;
  } catch (err) {
    print(err);
    return null;
  }
}
