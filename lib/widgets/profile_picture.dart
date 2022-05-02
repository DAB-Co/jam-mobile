import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jam/util/profile_pic_utils.dart';

Widget _profilePicture(ImageProvider img, double h, double w) {
  return GestureDetector(
    onTap: () => {},
    child: Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.contain,
          image: img,
        ),
      ),
    ),
  );
}

Widget bigProfilePicture(String id) {
  late String profilePicPath;

  Stream<bool> _profilePicExists() async* {
    while (true) {
      profilePicPath = await getOriginalProfilePicPath(id);
      yield File(profilePicPath).existsSync();
    }
  }

  return StreamBuilder(
      stream: _profilePicExists(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return _profilePicture(AssetImage('assets/avatar.png'), 200, 200);
          default:
            if ((snapshot.hasError) || !(snapshot.data as bool))
              return _profilePicture(AssetImage('assets/avatar.png'), 200, 200);
            else
              return _profilePicture(FileImage(File(profilePicPath)), 200, 200);
        }
      });
}

Widget smallProfilePicture(String id) {
  const double radius = 25;
  late String profilePicPath;

  Stream<bool> _profilePicExists() async* {
    while (true) {
      profilePicPath = await getSmallProfilePicPath(id);
      yield File(profilePicPath).existsSync();
    }
  }

  return StreamBuilder(
      stream: _profilePicExists(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/avatar.png"),
              radius: radius,
            );
          default:
            if ((snapshot.hasError) || !(snapshot.data as bool))
              return CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/avatar.png"),
                radius: radius,
              );
            else
              return CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: FileImage(File(profilePicPath)),
                radius: radius,
              );
        }
      },
  );
}
