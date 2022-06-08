import 'package:flutter/material.dart';

import '../main.dart';

AlertDialog inactiveDialog() {
  return AlertDialog(
    title: const Text("Attention!"),
    content: const Text("You were inactive for more than 24 hours. You did not get any matches when you were inactive. However, you are now an active user again and thus you will get a match today."),
    actions: [
      TextButton(
        child: Text("OK"),
        onPressed: () {
          navigatorKey.currentState?.pop();
        },
      )
    ],
  );
}
