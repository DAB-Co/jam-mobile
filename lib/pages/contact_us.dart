import 'package:flutter/material.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/contact_us_network.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/validators.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    final formKey = new GlobalKey<FormState>();
    String? _input;

    var doSend = () {
      final form = formKey.currentState!;
      if (form.validate()) {
        form.save();
        showSnackBar(context, "sending...", duration: 1);
        sendContactUsRequest(user, _input).then((isSuccessful) {
          if (isSuccessful) {
            showSnackBar(context, "successfully sent");
          } else {
            showSnackBar(context, "could not send");
          }
        });
      }
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(""),
        elevation: 0.1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Please send us your ideas and suggestions",
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    minLines: 12,
                    maxLines: null,
                    validator: validateNotEmpty,
                    onSaved: (value) => _input = value,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: longButtons("Send", doSend),
            ),
          ],
        ),
      ),
    );
  }
}
