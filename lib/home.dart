import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:pirate_music/PlaylistModel.dart';
import 'package:pirate_music/Store.dart';
import 'package:pirate_music/file_service.dart';
import 'package:pirate_music/main.dart';
import 'package:pirate_music/play_service.dart';

import 'InnerList.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List> getMusics() async {
    var list = io.Directory("/storage/emulated/0/Download/pirate_music").listSync();

    var modifiedList = [];

    for (var i in list) {
      if (i.path.substring(i.path.length - 4, i.path.length) == ".mp3") {
        modifiedList.add(i);
      }
    }
    return modifiedList;
  }

  var playBack = const Icon(Icons.play_arrow, size: 32, color: Colors.black);
  var playState = false;
  var bottomVisibility = false;
  final player = AudioPlayer();

  void playMusic() async {
    if (!playState) {
      setState(() {
        playBack = const Icon(Icons.pause, size: 32, color: Colors.black);
        playState = true;
      });

      await player.resume();
    } else {
      setState(() {
        playBack = const Icon(Icons.play_arrow, size: 32, color: Colors.black);
        playState = false;
      });

      await player.pause();
    }
  }

  var timeValue = 0.0;
  var duration = const Duration();
  var next = "";
  var last = false;
  var previous = -1;

  void onTapItem(String path) async {
    player.onDurationChanged.listen((Duration d) {
      setState(() {
        timeValue = 0.0;
        duration = d;
        getTime();
        setTimePosition();
        bottomVisibility = true;
        playBack = const Icon(Icons.pause, size: 32, color: Colors.black);
        playState = true;
      });
    });

    await player.stop();
    await player.play(DeviceFileSource(path));
  }

  var soundValue = 1.0;
  var volumeValue = 1.0;

  var soundBack = const Icon(Icons.volume_down, size: 32, color: Colors.black);
  var soundState = true;

  void onSoundClick() {
    if (soundState) {
      setState(() {
        soundBack =
            const Icon(Icons.volume_mute, size: 32, color: Colors.black);
        soundState = false;
        soundValue = 0.0;
      });
      player.setVolume(soundValue);
    } else {
      setState(() {
        soundBack =
            const Icon(Icons.volume_down, size: 32, color: Colors.black);
        soundState = true;
        soundValue = volumeValue;
      });
      player.setVolume(soundValue);
    }
  }

  var time = "0: 00/0:00";
  var min = 0;
  var sec = 0;

  void getTime() {
    var minuteD = duration.inMinutes.toString();

    var secondD = "${duration.inSeconds - int.parse(minuteD) * 60}";

    if (int.parse(secondD) < 10) {
      secondD = "0$secondD";
    }

    var minute = (duration.inSeconds * timeValue ~/ 60).toString();
    min = int.parse(minute);

    var second = (duration.inSeconds * timeValue - int.parse(minute) * 60)
        .toInt()
        .toString();
    sec = int.parse(second);

    if (int.parse(second) < 10) {
      second = "0$second";
    }

    time = "$minute:$second/$minuteD:$secondD";
  }

  void setTimePosition() {
    player.onPositionChanged.listen((event) {
      setState(() {
        timeValue = (event.inSeconds / duration.inSeconds);
        var minute = event.inMinutes.toString();
        var second = (event.inSeconds - event.inMinutes * 60).toString();
        if (int.parse(second) < 10) {
          second = "0$second";
        }

        var secondD = (duration.inSeconds - duration.inMinutes * 60).toString();
        if (int.parse(secondD) < 10) {
          secondD = "0$secondD";
        }

        time = "$minute:$second/${duration.inMinutes}:$secondD";

        if (event.inSeconds == duration.inSeconds) {
          if (!last) {
            onTapItem(next);
          } else {
            player.seek(Duration.zero);
            playMusic();
            timeValue = 0.0;
            time = "00:00/${time.substring(time.length - 4, time.length)}";
          }
        }
      });
    });
  }

  void skip() {
    if (!last) {
      setState(() {
        previous++;
        onTapItem(next);
      });
    }
  }

  void close() {
    setState(() {
      player.stop();
      bottomVisibility = false;
      previous = -1;
    });
  }

  List<List<PlayListModel>> theList = [];

  Future<String> getPlayLists(data) async {
    var path = "pirate_db";
    var service = PlayService(path: path);

    List<PlayListModel>? list = [];

    for (int i = 0; i < data.length; i++) {
      var path2 = "pirate_db2";
      var service2 = FileService(path: path2);

      if (await service.getAll() != null) {
        list = await service.getAll();
      }

      var allFiles = await service2
          .getAllByName(basename(data[i].path).replaceAll(".mp3", ""));

      if (allFiles != null) {
        for (int i = 0; i < allFiles.length; i++) {
          for (int j = 0; j < list!.length; j++) {
            if (allFiles[i].listId == list[j].id) {
              list.removeAt(j);
            }
          }
        }

        if (list!.isEmpty) {
          list.add(PlayListModel(name: ""));
        }
      }

      theList.add(list!);
      print(theList);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("My musics",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
        body: FutureBuilder(
            future: getMusics(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.data == null) {
                return const Text("Loading..");
              } else {
                var colorList = [];

                for (var i = 0; i < snapshot.data.length; i++) {
                  if (i == previous && previous != -1) {
                    colorList.add(const Color(0xfff7f2f9));
                  } else {
                    colorList.add(const Color(0x00ffffff));
                  }
                }

                return Scaffold(
                    body: FutureBuilder(
                        future: getPlayLists(snapshot.data),
                        builder: (context, AsyncSnapshot<dynamic> snapshot2) {
                          if (snapshot2.data == null) {
                            return Container();
                          } else {
                            return ListView.builder(
                                itemBuilder: (context, index) {
                                  return Container(
                                      color: colorList[index],
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 12, right: 12),
                                      margin: const EdgeInsets.only(
                                          top: 32, left: 16, right: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                previous = index;
                                                onTapItem(
                                                    snapshot.data[index].path);
                                                if (index !=
                                                    snapshot.data.length - 1) {
                                                  next = snapshot
                                                      .data[index + 1].path;
                                                } else {
                                                  last = true;
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                      child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(11),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8,
                                                                  right: 16),
                                                          color: Colors.blue,
                                                          child: const Icon(
                                                            Icons.music_note,
                                                            size: 32,
                                                          )),
                                                      Flexible(
                                                          child: Text(
                                                        basename(snapshot
                                                                .data[index]
                                                                .path)
                                                            .replaceAll(
                                                                ".mp3", ""),
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )),
                                                    ],
                                                  )),
                                                  DropdownButton<PlayListModel>(
                                                    icon: const Icon(
                                                        Icons.bookmark_outline,
                                                        size: 32,
                                                        color: Colors.black),
                                                    underline: Container(),
                                                    onChanged: (PlayListModel?
                                                        value) async {
                                                      setState(() {
                                                        var path = "pirate_db2";
                                                        var service = FileService(
                                                            path: path);
                                                        service.insert(Store(
                                                            name: basename(
                                                                snapshot
                                                                    .data[
                                                                index]
                                                                    .path)
                                                                .replaceAll(
                                                                ".mp3", ""),
                                                            path: snapshot
                                                                .data[index].path,
                                                            listId: value!.id!));
                                                      });
                                                    },
                                                    items: theList[index].map<
                                                            DropdownMenuItem<
                                                                PlayListModel>>(
                                                        (PlayListModel value) {
                                                      return DropdownMenuItem<
                                                          PlayListModel>(
                                                        value: value,
                                                        child: Text(value.name),
                                                      );
                                                    }).toList(),
                                                  )
                                                ],
                                              ))
                                        ],
                                      ));
                                },
                                itemCount: snapshot.data.length);
                          }
                        }),
                    bottomNavigationBar: Visibility(
                        visible: bottomVisibility,
                        child: Card(
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            elevation: 20,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      alignment: Alignment.topRight,
                                      padding: const EdgeInsets.only(
                                          top: 8, right: 8),
                                      child: InkWell(
                                        onTap: close,
                                        child: const Icon(Icons.close,
                                            color: Colors.black),
                                      )),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Slider(
                                                activeColor: Colors.indigo,
                                                value: timeValue,
                                                onChanged:
                                                    (double value) async {
                                                  setState(() {
                                                    timeValue = value;
                                                    getTime();
                                                  });
                                                  await player.seek(Duration(
                                                      minutes: min,
                                                      seconds: sec));
                                                })),
                                        Container(
                                            margin: const EdgeInsets.only(
                                                right: 16),
                                            child: Text(time,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)))
                                      ]),
                                  Row(
                                      children: [
                                    IconButton(
                                        onPressed: playMusic, icon: playBack),
                                    IconButton(
                                        onPressed: skip,
                                        icon: const Icon(
                                          Icons.skip_next,
                                          size: 32,
                                          color: Colors.black,
                                        )),
                                    IconButton(
                                        onPressed: onSoundClick,
                                        icon: soundBack),
                                    SizedBox(
                                      width: 150,
                                      child: Slider(
                                          value: soundValue,
                                          activeColor: Colors.white,
                                          onChanged: (double value) {
                                            setState(() {
                                              soundValue = value;
                                              volumeValue = value;
                                              player.setVolume(value);
                                            });
                                          }),
                                    ),
                                    Text((soundValue * 100).toInt().toString(),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                ]))));
              }
            }));
  }
}
