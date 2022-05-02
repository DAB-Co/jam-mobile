import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/show_snackbar.dart';

import '../main.dart';

/// Can be used with api calls that return OK on success.
/// Returns true on success
Future<bool> networkCall(Map<String, dynamic> dataToSend, String apiUrl) async {
  try {
    var response = await post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(dataToSend),
    );
    if (response.body == "OK") {
      return true;
    }
    if (response.body == "Wrong api token") {
      print("wrong api token in $apiUrl call");
      logout();
      showSnackBar(navigatorKey.currentContext!, "Wrong api token");
      return false;
    }
    return false;
  } catch (err) {
    print(err);
    return false;
  }
}
