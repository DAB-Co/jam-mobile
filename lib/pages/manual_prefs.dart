import 'package:flutter/material.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/goBackDialog.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

class Prefs extends StatefulWidget {
  @override
  _PrefsState createState() => _PrefsState();
}

bool okVisible = false;

class _PrefsState extends State<Prefs> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    List<dynamic>? prefs = ["a", "b", "c"];

    if (!ModalRoute.of(context)!.isFirst) {
      okVisible = false;
    }

    Container _circleListItem(String preference) => Container(
      margin: const EdgeInsets.all(10.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: (Color(0x88FF4081)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              preference,
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              splashRadius: 25,
              onPressed: () => print("removing $preference"),
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    Container _circlePrefItem(String preference) => Container(
      margin: const EdgeInsets.all(10.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: (Color(0x88FF4081)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              preference,
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              splashRadius: 25,
              onPressed: () => print("adding $preference"),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    void _openPrefPickerDialog() => showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.pink),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Available Preferences:",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  prefs == null || prefs.length == 0
                      ? Column(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.pinkAccent,
                      ),
                      SizedBox(height: 10),
                      const Text(
                        "Choose preferences.",
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                      : Container(
                    margin: EdgeInsets.only(bottom: okVisible ? 80 : 40),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: prefs.length,
                      itemBuilder: (context, index) {
                        return _circlePrefItem(prefs[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Future<bool> _goBack(BuildContext context) async {
      if (prefs == null || prefs.length == 0) {
        showDialog(
          context: context,
          builder: (context) => goBackDialog(context),
        );
      }
      return true;
    }

    return WillPopScope(
      onWillPop: () => _goBack(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text("User Preferences"),
          elevation: 0.1,
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Your Preferences:",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  prefs == null || prefs.length == 0
                      ? Column(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.pinkAccent,
                      ),
                      SizedBox(height: 10),
                      const Text(
                        "Choose preferences.",
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                      : Container(
                    margin: EdgeInsets.only(bottom: okVisible ? 80 : 40),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: prefs.length,
                      itemBuilder: (context, index) {
                        return _circleListItem(prefs[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    child: Column(
                      children: [
                        longButtons(
                          "OK",
                              () =>
                              Navigator.pushReplacementNamed(context, homepage),
                          color: Colors.green,
                        ),
                        SizedBox(
                          height: 10,
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    visible: okVisible,
                  ),
                  longButtons(
                    "Add a preference",
                    _openPrefPickerDialog,
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
