import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'musicPlayer_playing.dart';

var audioManagerInstance = AudioManager.instance;
// PlayMode playMode = audioManagerInstance.playMode;
bool isPlaying = false;
var slider;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  var songsList;

  fetchAllSongs() async {
    List<SongInfo> songs = await audioQuery.getSongs();
    setState(() {
      songsList = songs;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllSongs();
    print("This is My initState Fun..");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music Player",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter Music Player"),
        ),
        body: songsList != null
            ? ListView.builder(
                itemCount: songsList.length,
                itemBuilder: (context, index) {
                  SongInfo song = songsList[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayingNow(
                            currentSongPathToPlay: song.filePath,
                            title: song.title,
                            artist: song.artist,
                            artWork: song.albumArtwork,
                            displayName: song.displayName,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.black,
                        backgroundImage: song.albumArtwork != null
                            ? FileImage(File(song.albumArtwork))
                            : AssetImage("assets/music.png")),
                    title: Text(song.title),
                    subtitle: Text(song.artist),
                  );
                },
              )
            : null,
      ),
    );
  }
}
