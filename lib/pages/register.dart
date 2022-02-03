import 'package:flutter/material.dart';
import 'package:jam/widgets/app_bar.dart';
import 'package:jam/widgets/loading.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/validators.dart';
import '/widgets/form_widgets.dart';
import '../models/user.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  final formKey = new GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormFieldState>();
  final userNameFormKey = GlobalKey<FormFieldState>();
  final passwordFormKey = GlobalKey<FormFieldState>();
  final confirmPasswordFormKey = GlobalKey<FormFieldState>();

  String? _username, _email, _password, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final emailField = TextFormField(
      key: emailFormKey,
      onChanged: (_) => emailFormKey.currentState!.validate(),
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _email = value,
      decoration: buildInputDecoration("Enter email address", Icons.email),
    );

    final usernameField = TextFormField(
      key: userNameFormKey,
      onChanged: (_) => userNameFormKey.currentState!.validate(),
      autofocus: false,
      validator: validateUsername,
      onSaved: (value) => _username = value,
      decoration:
          buildInputDecoration("Enter username", Icons.supervised_user_circle),
    );

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

    var doRegister = () {
      final form = formKey.currentState!;
      if (form.validate()) {
        form.save();
        if (_password != _confirmPassword) {
          showSnackBar(context, "Passwords don't match.");
          return;
        }
        auth.register(_email, _username, _password).then((response) {
          if (response['status']) {
            User? user = response['user'];
            Provider.of<UserProvider>(context, listen: false)
                .setUser(user, context);
            Navigator.pushNamedAndRemoveUntil(context, routes.homepage, (Route<dynamic> route) => false);
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
                  SizedBox(height: 15.0),
                  Text("Username"),
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
                      ? loading("Registering ... Please wait")
                      : longButtons("Register", doRegister),
                  SizedBox(height: 30.0),
                  longButtons(
                    "Login if you have an account",
                    () => Navigator.pushNamed(context, routes.login),
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
