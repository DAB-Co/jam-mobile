import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/update_profile_pic.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/profile_pic_utils.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

class ProfilePicSelection extends StatefulWidget {
  @override
  _ProfilePicSelectionState createState() => _ProfilePicSelectionState();
}

class _ProfilePicSelectionState extends State<ProfilePicSelection> {
  final ImagePicker _picker = ImagePicker();
  bool waiting = false;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    return WillPopScope(
      onWillPop: () async => !waiting,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: Text("Profile Picture"),
          elevation: 0.1,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              if (!waiting) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: waiting
            ? Center(
                child: Text(
                "Please Wait...",
                style: TextStyle(
                  fontSize: 50,
                ),
                textAlign: TextAlign.center,
              ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            // wait for compression
                            setState(() {
                              waiting = true;
                            });
                            if (image == null) {
                              setState(() {
                                waiting = false;
                              });
                            } else {
                              var imageBytes = await File(image.path).readAsBytes();
                              bool success = await saveOwnPictureFromByteList(imageBytes, user);
                              if (!success) {
                                showSnackBar(context, "Check your connection.");
                                setState(() {
                                  waiting = false;
                                });
                              } else {
                                // go back to profile page
                                Navigator.pop(context);
                                // refresh for new profile picture
                                Navigator.pushReplacementNamed(context, profile);
                              }
                            }
                          },
                          child: const Text("Select From Gallery"),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => {
                            Navigator.pushReplacementNamed(
                                context, drawYourself)
                          },
                          child: const Text("Draw Yourself"),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      onPressed: () {
                        updateProfilePicCall(user, null, null).then((success) {
                          if (success) {
                            deleteProfilePicture(user.id!);
                            Navigator.pop(context);
                          } else {
                            showSnackBar(context, "Could not connect to the server");
                          }
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.delete, size: 16),
                            ),
                            TextSpan(
                              text: " Delete your profile picture",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
