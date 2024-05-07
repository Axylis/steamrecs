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

  OwnedGames({required this.appid, required this.playtime_forever,});

  factory OwnedGames.fromJson(Map<String, dynamic> json) {
    return OwnedGames(
      appid: json['appid'],
      playtime_forever: json['playtime_forever'],
      // Parse other fields here
    );
  }
}

class OwnedGamesDetail {
  final String name;
  List<String> genres;
  // Add more fields as needed

  OwnedGamesDetail({required this.name, required this.genres});

  factory OwnedGamesDetail.fromJson(Map<String, dynamic> json) {
    return OwnedGamesDetail(
      name: json['name'],
      genres: json['description'],
      // Parse other fields here
    );
  }
}




class GameListWidget extends StatelessWidget {
  final List<OwnedGames> games;

  GameListWidget({required this.games});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${games[index].appid}')
          // Add more fields here if needed
        );
      },
    );
  }
}


class SteamApiService {

  Future<List<OwnedGames>> GetOwnedGames(String steamIds) async {
    final response = await http.get(Uri.parse('https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=EBB0C29D061E421500F4401B108C3C4A&steamid=$steamIds'));
    //also add new api https://store.steampowered.com/api/appdetails?appids=appid
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['response']['games'];
      final List<OwnedGames> games = List<OwnedGames>.from(data.map<OwnedGames>((json) => OwnedGames.fromJson(json)));
       return games.where((game) => game.playtime_forever > 15).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }
  Future<List<OwnedGamesDetail>> GetGameGenres( appID) async {
    final response = await http.get(Uri.parse("https://steamspy.com/api.php?request=appdetails&appid=${appID}"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<OwnedGamesDetail> gameDetail = List<OwnedGamesDetail>.from(data.map<OwnedGamesDetail>((json) => OwnedGamesDetail.fromJson(json)));
       return gameDetail.toList();
    } else {
      throw Exception('Failed to load game details');
    }
  }

}



class _ResultsPageState extends State<ResultsPage> {

  List<OwnedGames> _games = [];
  List<OwnedGamesDetail> _gameDetails = [];

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
      for(var game in games)
      {
        final gamesDetail = await apiService.GetGameGenres(game.appid);
        setState(() {
          _gameDetails = gamesDetail;
        });
      }
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
      ),
      body: _games.isNotEmpty
          ? GameListWidget(games: _games)
          : Center(child: CircularProgressIndicator()),
      
      );
  }
}