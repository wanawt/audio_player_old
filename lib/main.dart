import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

typedef OnError = void Function(Exception exception);
const audiosString = '''{"body":[
    {"title":"空城计", "path":"audio1.mp3"},
    {"title":"穆桂英挂帅", "path":"audio2.mp3"},
    {"title":"女驸马", "path":"audio3.mp3"},
    {"title":"七品芝麻官", "path":"audio4.mp3"},
    {"title":"三哭殿", "path":"audio5.mp3"},
    {"title":"沙家浜智斗", "path":"audio6.mp3"},
    {"title":"苏三起解", "path":"audio7.mp3"},
    {"title":"锁麟囊", "path":"audio8.mp3"},
    {"title":"将相和", "path":"audio9.mp3"},
    {"title":"秦香莲1", "path":"audio10.mp3"},
    {"title":"秦香莲2", "path":"audio11.mp3"}]}''';
void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  int currentVideoIndex = 0;
  List<AudioPlayer> players =
  List.generate(4, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
  int selectedPlayerIdx = 0;
  final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  bool isAudioPlaying = false;
  List<String> allAudios = [];

  AudioPlayer get selectedPlayer => players[selectedPlayerIdx];
  List<StreamSubscription> streams = [];
  final map = json.decode(audiosString) as Map;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    player.onPlayerComplete.listen((event) {
      final list = map['body'] as List;
      if (list.length > currentVideoIndex) {
        setState(() {
          currentVideoIndex++;
        });
        final m = list[currentVideoIndex] as Map;
        playVideo(m['path'] as String);
      }
    });
  }

  Future<void> playVideo(String file) async {
    final assets = AssetSource(file);
    await player.play(assets);
  }

  @override
  void dispose() {
    streams.forEach((it) => it.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = map['body'] as List;
    return Scaffold(
      appBar: AppBar(
        title: const Text('戏曲'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final map = list[index] as Map;
                final isItemPlaying =
                    currentVideoIndex == index && isAudioPlaying;
                return GestureDetector(
                  child: ListTile(
                    selected: isItemPlaying,
                    title: Center(
                      child: Text(
                        map['title'] as String,
                        style: isItemPlaying
                            ? const TextStyle(fontSize: 30)
                            : const TextStyle(fontSize: 24),
                        // selectionColor: Colors.blue,
                      ),
                    ),
                  ),
                  onTap: () {
                    currentVideoIndex = index;
                    final m = list[currentVideoIndex] as Map;
                    playVideo(m['path'] as String);
                    setState(() {
                      isAudioPlaying = true;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.teal[50],
              child: Center(
                child:Container(
                width: 110,
                height: 110,
                child: FloatingActionButton(
                  backgroundColor:
                  isAudioPlaying ? Colors.red : Colors.blue,
                  onPressed: () {
                    setState(() {
                      if (player.state == PlayerState.playing) {
                        player.pause();
                        isAudioPlaying = false;
                      } else {
                        final m = list[currentVideoIndex] as Map;
                        playVideo(m['path'] as String);
                        isAudioPlaying = true;
                      }
                    });
                  },
                  child: isAudioPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow_rounded),
                ),
              ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      log('应用进入后台 paused');
      // player.pause();
    } else if (state == AppLifecycleState.resumed) {
      log('应用进入前台 resumed');
    } else if (state == AppLifecycleState.inactive) {
      // 应用进入非活动状态 , 如来了个电话 , 电话应用进入前台 本应用进入该状态
      log('应用进入非活动状态 inactive');
    } else if (state == AppLifecycleState.detached) {
      // 应用程序仍然在 Flutter 引擎上运行 , 但是与宿主 View 组件分离
      log('应用进入 detached 状态 detached');
    }
  }
}
