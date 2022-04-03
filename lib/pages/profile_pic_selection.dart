import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/util_functions.dart';
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
          title: Text(""),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        XFile? image =
                            await _picker.pickImage(source: ImageSource.gallery);
                        if (image == null) return;
                        // copy the file to a new path
                        File imageFile = File(image.path);
                        String path = await getProfilePicPath(user.id!);
                        await imageFile.copy(path);
                        // compress
                        setState(() {
                          waiting = true;
                        });
                        await compressAndGetFile(File(image.path), path);
                        // clear image cache, IMPORTANT
                        imageCache?.clear();
                        imageCache?.clearLiveImages();
                        // go back to profile page
                        Navigator.pop(context);
                        // refresh for new profile picture
                        Navigator.pushReplacementNamed(context, profile);
                      },
                      child: const Text("Select From Gallery"),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => {},
                      child: const Text("Draw Yourself"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
