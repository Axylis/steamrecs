import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:skripsi_finals/homescreen.dart';
import 'package:skripsi_finals/pages/steam_login.dart';
import 'package:steam_login/steam_login.dart';
import 'dart:io';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key,});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String steamID = "";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Color.fromARGB(255, 23, 42, 110),
        // Here we take the value from the LoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Log In Through STEAM',
              style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 221, 221, 221)),
            ),
            TextButton(
              onPressed:() async {
                final result = await Navigator.push(context, 
                MaterialPageRoute(builder: (context) => SteamLogin()),
                );
                setState(() {
                  steamID = result;
                });
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => HomeScreen(title: 'SteamRecs', steamID: steamID, index: 0,)),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27)), child: const Text('Login Page')
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  
}

