import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pirate_music/download.dart';
import 'package:pirate_music/home.dart';
import 'package:pirate_music/playlist.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(body: Main()),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  Widget currentScreen = const Home();

  int _selectedIndex = 0;
  var screens = [const Home(), const Download(), const Playlist()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      currentScreen = screens[_selectedIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: currentScreen, bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.download), label: "Download"),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Playlists"),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    ));
  }
}
