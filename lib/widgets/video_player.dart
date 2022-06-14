import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../pages/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({Key? key, required this.videoPath})
      : super(key: key);
  final String videoPath;

  @override
  _CustomVideoPlayerState createState() =>
      _CustomVideoPlayerState(videoPath: videoPath);
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  _CustomVideoPlayerState({required this.videoPath}) : super();
  final String videoPath;

  late VideoPlayerController _controller;
  bool videoExists = true;

  @override
  void initState() {
    super.initState();
    if (!File(videoPath).existsSync()) {
      videoExists = false;
    }
    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!videoExists) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.red,
        ),
        padding: EdgeInsets.all(16),
        child: Text(
          "Video deleted",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return Stack(
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
        Positioned.fill(
          child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: RouteSettings(name: "video player"),
                        builder: (context) => VideoApp(videoPath: videoPath)),
                  );
                },
                child: Icon(Icons.play_arrow),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
                ),
              ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
