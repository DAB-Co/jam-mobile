import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/show_snackbar.dart';

import '../main.dart';

/// Call get_languages from server.
/// Logs out if api token was invalid,
/// If call was successful it writes to hive box
Future<List<String>?> getLanguagesCall(
  String userId,
  String apiToken,
  String otherId,
) async {
  final Map<String, String> userData = {
    "user_id": userId,
    "api_token": apiToken,
    "req_user": otherId,
  };
  try {
    var response = await post(
      Uri.parse(AppUrl.getLanguages),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(userData),
    );
    if (response.body == "Wrong api token") {
      print("wrong api token");
      logout();
      showSnackBar(navigatorKey.currentContext!, "Wrong api token");
    }
    if (response.statusCode != 200) {
      print(response);
      return null;
    }
    List<String> decoded = jsonDecode(response.body).map((iso)=>iso.toLowerCase()).toList().cast<String>();
    return decoded;
  } catch (err) {
    print(err);
    return null;
  }
}
