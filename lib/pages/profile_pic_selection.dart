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

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(""),
        elevation: 0.1,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image == null) return;
                File imageFile = File(image.path);
                String path = await getProfilePicPath(user.id!);
                // copy the file to a new path
                await imageFile.copy(path);
                imageCache?.clear();
                imageCache?.clearLiveImages();
                // TODO compress and save
                // returns null, fix later
                // testCompressAndGetFile(File(image.path), path);
                Navigator.pop(context);
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
    );
  }
}
