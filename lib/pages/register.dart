import 'package:flutter/material.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '/domain/user.dart';
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/validators.dart';
import '/widgets/form_widgets.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();

  String? _username, _password, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final usernameField = TextFormField(
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _username = value,
      decoration: buildInputDecoration("Enter email address", Icons.email),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => validatePassword(value),
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration("Enter password", Icons.lock),
    );

    final confirmPassword = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? "Your password is required" : null,
      onSaved: (value) => _confirmPassword = value,
      decoration: buildInputDecoration("Confirm password", Icons.lock),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Registering ... Please wait")
      ],
    );

    var doRegister = () {
      final form = formKey.currentState!;
      if (form.validate()) {
        form.save();
        if (_password != _confirmPassword) {
          showSnackBar(context, "Passwords don't match.");
          return;
        }
        auth.register(_username, _password).then((response) {
          if (response['status']) {
            User? user = response['data'];
            Provider.of<UserProvider>(context, listen: false).setUser(user, context);
            Navigator.pushReplacementNamed(context, routes.homepage);
          } else {
            showSnackBar(context, response['message']);
          }
        });
      } else {
        showSnackBar(context, "Please complete the form properly");
      }
    };

    return SafeArea(
      child: Scaffold(
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
                  usernameField,
                  SizedBox(height: 15.0),
                  Text("Password"),
                  SizedBox(height: 10.0),
                  passwordField,
                  SizedBox(height: 15.0),
                  Text("Confirm Password"),
                  SizedBox(height: 10.0),
                  confirmPassword,
                  SizedBox(height: 20.0),
                  auth.loggedInStatus == Status.Authenticating
                      ? loading
                      : longButtons("Register", doRegister),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
