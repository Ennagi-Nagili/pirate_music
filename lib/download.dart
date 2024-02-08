import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class Download extends StatelessWidget {
  const Download({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DownloadMain(),
    );
  }
}

class DownloadMain extends StatefulWidget {
  const DownloadMain({super.key});

  @override
  State<DownloadMain> createState() => _DownloadMainState();
}

class _DownloadMainState extends State<DownloadMain> {
  final TextEditingController inputController = TextEditingController();
  var percent = 0.0;
  var complete = "";
  var visibility = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              percent = (received / total);
            });
          }
        },
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      setState(() {
        complete = "Done";
      });
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  Future<String> getFolder(var fileName) async {
    final saveDirectory =
    Directory("/storage/emulated/0/Download/pirate_music");

    if (await saveDirectory.exists()) {
      return "${saveDirectory.path}/$fileName";
    } else {
      final Directory newDirectory =
      await saveDirectory.create(recursive: true);
      return "${newDirectory.path}/$fileName";
    }
  }

  void requestAudio() async {
    setState(() {
      visibility = true;
      percent = 0;
    });

    try {
      Dio dio = Dio();
      dio.options.headers['X-RapidAPI-Key'] =
      '1120fb7574mshb30d812cab65573p12c987jsnb244bf06a741';
      dio.options.headers['X-RapidAPI-Host'] =
      'youtube-mp3-download-highest-quality1.p.rapidapi.com';
      Response response = await dio.get(
          "https://youtube-mp3-download-highest-quality1.p.rapidapi.com/ytmp3/ytmp3/custom/?url=${inputController
              .text}&quality=256");
      //launchURL(response.data["link"].toString());

      var fileName = response.data["title"].toString().replaceAll(" ", "_");
      fileName += ".mp3";

      final savePath = await getFolder(fileName);
      download2(Dio(), response.data["link"].toString(), savePath);
    } on DioException catch (e) {
      print("errr: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Download music",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: inputController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Enter url..."),
                  )),
              Visibility(visible: visibility, child: Column(children: [
                Container(margin: const EdgeInsets.only(left: 16, right: 16,
                    top: 32, bottom: 16),
                    child: LinearProgressIndicator(value: percent,
                        color: Colors.blue, minHeight: 10)),
                Text(complete, style: const TextStyle(fontSize: 24,
                    fontWeight: FontWeight.w500))
              ]),),
              Container(margin: const EdgeInsets.only(top: 32), child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                onPressed: () {
                  setState(() {
                    complete = "Loading...";
                  });
                  requestAudio();
                },
                child: Container(
                    padding: const EdgeInsets.all(14),
                    child: const Text('Download',
                        style: TextStyle(
                            fontSize: 24, color: Colors.white))),
              ))
            ])));
  }
}
