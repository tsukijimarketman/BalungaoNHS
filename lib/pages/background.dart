import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideoPlayer extends StatefulWidget {
  const BackgroundVideoPlayer({super.key});

  @override
  State<BackgroundVideoPlayer> createState() => _BackgroundVideoPlayerState();
}

class _BackgroundVideoPlayerState extends State<BackgroundVideoPlayer> {
  late final VideoPlayerController controller;
  @override
  void initState() {
    controller = VideoPlayerController.asset("assets/vid/vid.mp4")
      ..initialize().then((_) {
        controller.play();
        controller.setLooping(true);

      });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) => VideoPlayer(controller);
}
