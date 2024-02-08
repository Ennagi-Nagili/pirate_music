import 'package:flutter/material.dart';
import 'package:pirate_music/InnerList.dart';
import 'package:pirate_music/PlaylistModel.dart';
import 'package:pirate_music/file_service.dart';
import 'package:pirate_music/play_service.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  Future<List<PlayListModel>?> getPlayLists() {
    var path = "pirate_db";
    var service = PlayService(path: path);

    return service.getAll();
  }

  final TextEditingController inputController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  void add() async {
    var path = "pirate_db";
    var service = PlayService(path: path);
    if (inputController.text.isNotEmpty) {
      setState(() {
        service.insert(PlayListModel(name: inputController.text));
      });
    }
  }

  void delete(id) {
    var path = "pirate_db";
    var service = PlayService(path: path);
    var path2 = "pirate_db2";
    var service2 = FileService(path: path2);

    service2.deleteByListId(id);
    setState(() {
      service.delete(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              const Text("My playlists",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(
                  width: 60,
                  height: 60,
                  child: IconButton(
                      icon: const Icon(Icons.add, size: 42),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                content: SizedBox(
                                    width: 500,
                                    child: TextField(
                                      controller: inputController,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Enter playlist name"),
                                    )),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => {
                                      add(),
                                      Navigator.pop(context, 'OK'),
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ))))
            ])),
        body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: FutureBuilder(
                future: getPlayLists(),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  } else {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => InnerList(
                                              id: snapshot.data[index].id,
                                              name:
                                                  snapshot.data[index].name)));
                                },
                                child: Card(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 24,
                                                      horizontal: 16),
                                              child: const Icon(
                                                  Icons.library_music,
                                                  size: 42,
                                                  color: Colors.blue),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    snapshot.data[index].name,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500)))
                                          ]),
                                      IconButton(
                                          onPressed: () {
                                            delete(snapshot.data[index].id);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 32,
                                            color: Colors.black,
                                          ))
                                    ],
                                  ),
                                )));
                      },
                      itemCount: snapshot.data.length,
                    );
                  }
                })));
  }
}
