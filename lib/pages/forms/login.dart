import 'package:flutter/material.dart';
import 'package:jam/widgets/app_bar.dart';
import 'package:jam/widgets/loading.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '../../models/user.dart';
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/validators.dart';
import '/widgets/form_widgets.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();

  String? _email, _password;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _email = value,
      decoration: buildInputDecoration("Enter email address", Icons.email),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? "Please enter password" : null,
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration("Enter your password", Icons.lock),
    );

    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextButton(
          child: Text(
            "Forgot password?",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            showSnackBar(context, "Will be implemented soon");
          },
        ),
        TextButton(
          child: Text(
            "Register",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, routes.register, (Route<dynamic> route) => false);
          },
        ),
      ],
    );

    var doLogin = () {
      final form = formKey.currentState!;

      if (form.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulMessage =
            auth.login(_email, _password);

        successfulMessage.then((response) {
          if (response['status']) {
            User? user = response['user'];
            Provider.of<UserProvider>(context, listen: false)
                .setUser(user, context);
            Navigator.pushNamedAndRemoveUntil(context, routes.homepage, (Route<dynamic> route) => false);
          } else {
            showSnackBar(context, response["message"]);
          }
        });
      } else {
        showSnackBar(context, "Please complete the form properly");
      }
    };

    return SafeArea(
      child: Scaffold(
        appBar: formAppBar(),
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
                  Text("Password"),
                  SizedBox(height: 5.0),
                  passwordField,
                  SizedBox(height: 20.0),
                  auth.loggedInStatus == Status.Authenticating
                      ? loading("Authenticating ... Please wait")
                      : longButtons("Login", doLogin),
                  SizedBox(height: 5.0),
                  forgotLabel
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
