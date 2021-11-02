import 'package:flutter/material.dart';
import '/domain/user.dart';
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/validators.dart';
import '/util/widgets.dart';
import 'package:provider/provider.dart';
import "/util/routes.dart" as routes;

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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Passwords don't match."),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
          ));
          return;
        }
        auth.register(_username, _password).then((response) {
          if (response['status']) {
            User? user = response['data'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.pushReplacementNamed(context, routes.homepage);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response['message']),
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
            ));
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please Complete the form properly"),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black,
        ));
      }

    };

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.0),
                label("Email"),
                SizedBox(height: 5.0),
                usernameField,
                SizedBox(height: 15.0),
                label("Password"),
                SizedBox(height: 10.0),
                passwordField,
                SizedBox(height: 15.0),
                label("Confirm Password"),
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
    );
  }
}
