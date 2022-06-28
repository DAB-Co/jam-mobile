import 'package:flutter/material.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/network/change_password.dart';
import 'package:jam/util/validators.dart';
import 'package:jam/widgets/app_bar.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/loading.dart';
import 'package:jam/widgets/show_snackbar.dart';

class ChangePassword extends StatefulWidget {
  final String token;

  const ChangePassword(this.token, {Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState(token);
}

class _ChangePasswordState extends State<ChangePassword> {
  final String token;
  _ChangePasswordState(this.token) : super();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  final formKey = new GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormFieldState>();
  final confirmPasswordFormKey = GlobalKey<FormFieldState>();

  String? _password, _confirmPassword;
  bool waitingForResponse = false;

  @override
  Widget build(BuildContext context) {

    final passwordField = TextFormField(
      key: passwordFormKey,
      controller: passwordController,
      onChanged: (_) => passwordFormKey.currentState!.validate(),
      autofocus: false,
      obscureText: true,
      validator: (value) => validatePassword(value),
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration("Enter password", Icons.lock),
    );

    final confirmPassword = TextFormField(
      key: confirmPasswordFormKey,
      onChanged: (_) => confirmPasswordFormKey.currentState!.validate(),
      autofocus: false,
      obscureText: true,
      validator: (value) =>
      (value != passwordController.text) ? "Passwords don't match" : null,
      onSaved: (value) => _confirmPassword = value,
      decoration: buildInputDecoration("Confirm password", Icons.lock),
    );

    var submit = () async {
      final form = formKey.currentState!;

      if (form.validate()) {
        form.save();
        if (_password != _confirmPassword) {
          showSnackBar(context, "Passwords don't match.");
          return;
        }
        if (_password == null || _confirmPassword == null) return;

        setState(() {
          waitingForResponse = true;
        });

        String? serverResponse = await sendChangePasswordRequest(_password!, token);
        if (serverResponse == null) {
          showSnackBar(context, "Check your connection");
        } else if (serverResponse == "OK") {
          Navigator.pushReplacementNamed(context, login);
          showSnackBar(context, "Password changed successfully");
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
                  Text("New Password"),
                  SizedBox(height: 5.0),
                  passwordField,
                  SizedBox(height: 15.0),
                  Text("Confirm New Password"),
                  SizedBox(height: 5.0),
                  confirmPassword,
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
