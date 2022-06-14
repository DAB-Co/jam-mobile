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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
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
