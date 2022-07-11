import 'package:flutter/material.dart';
import 'package:jam/network/forgot_password.dart';
import 'package:jam/util/validators.dart';
import 'package:jam/widgets/app_bar.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/loading.dart';
import 'package:jam/widgets/show_snackbar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final formKey = new GlobalKey<FormState>();
  String? _email;
  bool waitingForResponse = false;

  @override
  Widget build(BuildContext context) {

    final emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _email = value,
      decoration: buildInputDecoration("Enter email address", Icons.email),
    );

    var submit = () async {
      final form = formKey.currentState!;

      if (form.validate()) {
        form.save();
        if (_email == null) return;

        setState(() {
          waitingForResponse = true;
        });

        String? serverResponse = await sendForgotPasswordRequest(_email!);
        if (serverResponse == null) {
          showSnackBar(context, "Check your connection");
        } else if (serverResponse == "OK") {
          showSnackBar(context, "Success! Please check your email");
        } else if (serverResponse.contains("Cannot POST")) {
          showSnackBar(context, "Cannot post forgot_password");
        } else {
          showSnackBar(context, serverResponse);
        }

        setState(() {
          waitingForResponse = false;
        });
      } else {
        showSnackBar(context, "Please complete the form properly");
      }
    };

    return SafeArea(
      child: Scaffold(
        appBar: formAppBar(backButtonVisible: true),
        body: Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.0),
                  Text("Email"),
                  SizedBox(height: 5.0),
                  emailField,
                  SizedBox(height: 20.0),
                  waitingForResponse
                      ? loading("Please wait...")
                      : longButtons("Submit", submit),
                  SizedBox(height: 5.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
