import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<Game> games;

  OwnedGames({required this.games});
  factory OwnedGames.fromJson(Map<String, dynamic> json) {
    var gamesJson = json['response']['games'] as List;
    List<Game> gamesList = gamesJson.map((i) => Game.fromJson(i)).toList();
    return OwnedGames(games: gamesList);
  }
}

class Game {
  final int appid;
  final int playtime_forever;

  Game({required this.appid, required this.playtime_forever});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      appid: json['appid'],
      playtime_forever: json['playtime_forever'],
    );
  }
}

class GameGenre {
  final String genre;

  GameGenre({required this.genre});

  factory GameGenre.fromJson(Map<String, dynamic> json) {
    return GameGenre(
      genre: json['genre'] as String,
    );
  }
}

class JsonGameList{
  final int appid;
  final String name;
  final String genre;

  JsonGameList({required this.appid, required this.name, required this.genre});

  factory JsonGameList.fromJson(Map<String, dynamic> json) {
    return JsonGameList(
      appid: json['appid'] as int,
      name: json['name'] as String,
      genre: json['genre'] as String,
    );
  }
}

List<JsonGameList> parseGameLists(String jsonString) {
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  List<JsonGameList> gamesList = [];

  jsonMap.forEach((key, value) {
    gamesList.add(JsonGameList.fromJson(value));
  });

  return gamesList;
}

class SteamApiService {


  Future<OwnedGames> GetOwnedGames(String steamIds) async {
    final response = await http.get(Uri.parse('https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=EBB0C29D061E421500F4401B108C3C4A&steamid=$steamIds'));
    if (response.statusCode == 200) {
      OwnedGames ownedGames = OwnedGames.fromJson(jsonDecode(response.body));
      List<Game> filteredGames = ownedGames.games.where((game) => game.playtime_forever > 15).toList();
      return OwnedGames(games: filteredGames);
    } else {
      throw Exception('Failed to load owned games');
    }
  }

}

class SteamSpyService {

  Future<GameGenre> fetchGameInfo(int appid) async {
    final response = await http.get(Uri.parse('https://steamspy.com/api.php?request=appdetails&appid=$appid'));
    //also add new api https://store.steampowered.com/api/appdetails?appids=appid
    if (response.statusCode == 200) {
      return GameGenre.fromJson(jsonDecode(response.body));

    } else {
      throw Exception('Failed to load game info');
    }
  }

}

class LocalJsonService {
  Future<List<JsonGameList>> loadGames() async {
    final jsonString = await rootBundle.loadString('assets/steam_games.json');
    return compute(parseGameLists, jsonString);
  }
}




class _ResultsPageState extends State<ResultsPage> {

  final steamAPI = SteamApiService();
  final steamSpyAPI = SteamSpyService();
  final localJsonService = LocalJsonService();
  Future<OwnedGames>? _ownedGamesFuture;
  Map<int, Future<GameGenre>> _gameGenreFutures = {};
  late Future<List<JsonGameList>> futureJsonGames;

  List<OwnedGames>? _games = [];
  List<String> genre = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ownedGamesFuture = steamAPI.GetOwnedGames(widget.steamID);
    futureJsonGames = localJsonService.loadGames();
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
      body: FutureBuilder<OwnedGames>(
        future: _ownedGamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.games.isEmpty) {
            return Center(child: Text('No games found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.games.length,
              itemBuilder: (context, index) {
                var game = snapshot.data!.games[index];
                if (!_gameGenreFutures.containsKey(game.appid)) {
                  _gameGenreFutures[game.appid] = steamSpyAPI.fetchGameInfo(game.appid);
                }
                return FutureBuilder<GameGenre>(
                  future: _gameGenreFutures[game.appid],
                  builder: (context, gameInfoSnapshot) {
                    if (gameInfoSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Game ID: ${game.appid}'),
                        subtitle: Text('Loading genre...'),
                      );
                    } else if (gameInfoSnapshot.hasError) {
                      return ListTile(
                        title: Text('Game ID: ${game.appid}'),
                        subtitle: Text('Error: ${gameInfoSnapshot.error}'),
                      );
                    } else if (!gameInfoSnapshot.hasData) {
                      return ListTile(
                        title: Text('Game ID: ${game.appid}'),
                        subtitle: Text('No genre found'),
                      );
                    } else {
                      return ListTile(
                        title: Text('Game ID: ${game.appid}'),
                        subtitle: Text('Genre: ${gameInfoSnapshot.data!.genre}'),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}