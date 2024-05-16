import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:skripsi_finals/homescreen.dart';
import 'package:skripsi_finals/pages/results.dart';
import 'package:skripsi_finals/pages/recommender.dart';
import 'package:skripsi_finals/pages/steam_login.dart';
import 'package:skripsi_finals/pages/test.dart';

class HomeScreenPage extends StatefulWidget {
  final String steamID;

  @override
  const HomeScreenPage({super.key, required this.steamID});
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
{

  @override
  Widget build(BuildContext context) {
   return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 60),
          Center(
            child: TextButton(
              onPressed:() {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => ResultsPage(steamID: widget.steamID,)),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27),shape: CircleBorder(), padding: EdgeInsets.all(100)), child: const Text('Quick Recommender',)
            ),
          ),
          SizedBox(height: 40,),
          Center(
            child: TextButton(
              onPressed:() {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => HomeScreen(title:"Steamworks", steamID: widget.steamID, index: 1,)),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27)), child: const Text('Custom Recommendations')
            ),
          ),
          Center(
            child: TextButton(
              onPressed:() {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => TestPage()),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27)), child: const Text('Test')
            ),
          )
        ],
        )      
   );
  }
  
}

