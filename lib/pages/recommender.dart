import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:skripsi_finals/pages/recentResults.dart';
import 'package:skripsi_finals/pages/results.dart';

class RecommenderPage extends StatefulWidget {
  const RecommenderPage({super.key, required this.steamID});

  final String steamID;

  @override
  State<RecommenderPage> createState() => _RecommenderPageState();
}


class _RecommenderPageState extends State<RecommenderPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text("Recommend by: ", style: TextStyle(fontSize: 30, color: const Color.fromARGB(223, 255, 255, 255),),),
          SizedBox(height: 70,),
          Center(
            child: TextButton(
              onPressed:() {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => ResultsPage(steamID: widget.steamID,)),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27), padding: EdgeInsets.all(20), ), child: const Text('Games you owned')
            ),
          ),
          SizedBox(height: 40,),
          Center(
            child: TextButton(
              onPressed:() {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => RecentResultsPage(steamID: widget.steamID,)),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27), padding: EdgeInsets.all(20)),  child: const Text('Recently Played Games')
            ),
          ),
          SizedBox(height: 40,),
          Center(
            child: Text("It may take a while for the recommendations to load, especially on bigger game libraries", style: TextStyle(color: const Color.fromARGB(239, 255, 255, 255), fontSize: 12), textAlign: TextAlign.center,)
            )
        ],
        )  
      );
  }
}