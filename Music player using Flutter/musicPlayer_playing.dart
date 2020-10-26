import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'musicPlayer_home.dart';

class PlayingNow extends StatefulWidget {
  final currentSongPathToPlay;
  final title;
  final artist;
  final artWork;
  final displayName;
  PlayingNow({
    this.currentSongPathToPlay,
    this.title,
    this.artist,
    this.artWork,
    this.displayName,
  });
  @override
  _PlayingNowState createState() => _PlayingNowState();
}

class _PlayingNowState extends State<PlayingNow> {
  playSong() {
    audioManagerInstance.start(
      "file://${widget.currentSongPathToPlay}",
      widget.title,
      desc: widget.displayName,
      auto: true,
      cover: "assets/music.png",
    );
  }

  void setAudio() {
    audioManagerInstance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.start:
          slider = 0;
          break;
        case AudioManagerEvents.seekComplete:
          slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          setState(() {});
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = audioManagerInstance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          audioManagerInstance.updateLrc(args["position"].toString());
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setAudio();
    playSong();
  }

  String formatDuration(Duration d) {
    if (d == null) return "--:--";
    int m = d.inMinutes;
    int s = d.inSeconds % 60;
    String time = ((m < 10) ? "0$m" : "$m") + ":" + ((s < 10) ? "0$s" : "$s");
    return time;
  }

  Widget songProgrssBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(
            formatDuration(audioManagerInstance.position),
            style: TextStyle(
              fontSize: 18.5,
              color: Colors.green[50],
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbColor: Colors.green[50],
                overlayColor: Colors.red,
                thumbShape: RoundSliderThumbShape(
                  disabledThumbRadius: 5,
                  enabledThumbRadius: 5,
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: 10,
                ),
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.black12,
              ),
              child: Slider(
                value: slider,
                onChanged: (value) {
                  setState(() {
                    slider = value;
                  });
                },
                onChangeEnd: (value) {
                  if (audioManagerInstance.duration != null) {
                    Duration msec = Duration(
                        milliseconds:
                            (audioManagerInstance.duration.inMilliseconds *
                                    value)
                                .round());
                    audioManagerInstance.seekTo(msec);
                  }
                },
              ),
            ),
          )),
          Text(
            formatDuration(audioManagerInstance.duration),
            style: TextStyle(
              fontSize: 18.5,
              color: Colors.green[50],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.artWork == null
                ? AssetImage("assets/music.png")
                : FileImage(
                    File(widget.artWork),
                  ),
            fit: BoxFit.fill,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(),
          child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
              child: ListView(
                padding: EdgeInsets.all(8.0),
                children: [
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  Center(
                    child: Image(
                      image: widget.artWork == null
                          ? AssetImage("assets/music.png")
                          : FileImage(
                              File(widget.artWork),
                            ),
                      width: 240,
                      height: 240,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 15.0),
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            widget.artist,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  songProgrssBar(context),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                      child: IconButton(
                        iconSize: 50,
                        color: Colors.black,
                        icon: audioManagerInstance.isPlaying
                            ? Icon(
                                Icons.pause_circle_outline,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                              ),
                        onPressed: () {
                          audioManagerInstance.playOrPause();
                        },
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
