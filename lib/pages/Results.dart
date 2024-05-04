import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:skripsi_finals/pages/homeScreenPage.dart';
import 'package:skripsi_finals/pages/recommender.dart';
import 'package:skripsi_finals/homescreen.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key, required this.steamID});

  final String steamID;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class OwnedGames {
  final int appid;
  final int playtime_forever;
  // Add more fields as needed

  OwnedGames({required this.appid, required this.playtime_forever});

  factory OwnedGames.fromJson(Map<String, dynamic> json) {
    return OwnedGames(
      appid: json['appid'],
      playtime_forever: json['playtime_forever'],
      // Parse other fields here
    );
  }
}


class SteamApiService {

  Future<List<OwnedGames>> GetOwnedGames(String steamIds) async {
    final response = await http.get(Uri.parse('https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=EBB0C29D061E421500F4401B108C3C4A&steamid=$steamIds'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['response']['games'];
       return data.map((json) => OwnedGames.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load player summaries');
    }
  }
}

class _ResultsPageState extends State<ResultsPage> {

  List<OwnedGames> _games = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchOwnedGames();
  }

  Future<void> _fetchOwnedGames() async {
    try {
      final apiService = SteamApiService();
      final games = await apiService.GetOwnedGames(widget.steamID);
      setState(() {
        _games = games;
      });
    } catch (e) {
      print('Error fetching player summaries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        },
        ),
      )
      ,
      body: GridView.count(
        crossAxisCount: 3,
        children: <Widget>[
          GestureDetector(
            child: Card(
              child: Text('{$_games.appid}'),
            ),
          )
        ]
        )
      );
  }
}