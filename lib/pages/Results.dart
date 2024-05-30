import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

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
  final Map<String, int> tags;

  GameGenre({required this.tags});

  factory GameGenre.fromJson(Map<String, dynamic> json) {
    return GameGenre(
      tags: Map<String, int>.from(json['tags'] as Map),
    );
  }
}

class JsonGameList{
  final int appid;
  final String name;
  final Map<String, int> tags;
  final double similarityIndex;

  JsonGameList({required this.appid, required this.name, required this.tags, required this.similarityIndex});

  factory JsonGameList.fromJson(Map<String, dynamic> json) {
    return JsonGameList(
      appid: json['appid'] as int,
      name: json['name'] as String,
      tags: Map<String, int>.from(json['tags'] as Map),
      similarityIndex: 0.0,
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

Map<String, int> _buildTagVector(Set<String> tags) {
  Map<String, int> vector = {};
  for (var tag in tags) {
    // Clean the tag: remove special characters and convert to lowercase
    String cleanedTag = tag.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    
    // Check if the tag contains any ignore words
    bool shouldIgnore = false;
    for (var word in ignoreWords) {
      if (cleanedTag.contains(word)) {
        shouldIgnore = true;
        break;
      }
    }

    // Add to vector if it is not to be ignored and is not empty
    if (!shouldIgnore && cleanedTag.isNotEmpty) {
      vector[cleanedTag] = 1;
    }
  }
  return vector;
}
Set<String> ignoreWords = {'sexualcontent', 'hentai', 'utilities', 'gamedevelopment'};

Future<List<JsonGameList>> _findSimilarGames(Map<String, dynamic> params) async {
  List<dynamic> jsonGames = params['jsonGames'];
  Set<String> playerTags = Set<String>.from(params['playerTags']);

  Map<String, int> playerVector = _buildTagVector(playerTags);

  double _cosineSimilarity(Map<String, int> vecA, Map<String, int> vecB) {
    int dotProduct = 0;
    double magnitudeA = 0;
    double magnitudeB = 0;

    for (var key in vecA.keys) {
      if (vecB.containsKey(key)) {
        dotProduct += vecA[key]! * vecB[key]!;
      }
      magnitudeA += math.pow(vecA[key]!, 2);
    }

    for (var key in vecB.keys) {
      magnitudeB += math.pow(vecB[key]!, 2);
    }

    if (magnitudeA == 0 || magnitudeB == 0) {
      return 0.0;
    }

    return dotProduct / (math.sqrt(magnitudeA) * math.sqrt(magnitudeB));
  }

  List<Map<String, dynamic>> gameSimilarities = [];

  for (var game in jsonGames) {
    var gameTags = Set<String>.from((game['tags'] as Map).keys);
    Map<String, int> gameVector = _buildTagVector(gameTags);

    double similarity = _cosineSimilarity(playerVector, gameVector);
    if (similarity > 0) {
      gameSimilarities.add({'game': game, 'similarity': similarity});
    }
  }

  gameSimilarities.sort((a, b) => b['similarity'].compareTo(a['similarity']));

  return gameSimilarities.take(10).map((item) => JsonGameList(
    appid: item['game']['appid'],
    name: item['game']['name'],
    tags: Map<String, int>.from(item['game']['tags']),
    similarityIndex: item['similarity'],
  )).toList();
}



class _ResultsPageState extends State<ResultsPage> {

  final steamAPI = SteamApiService();
  final steamSpyAPI = SteamSpyService();
  final localJsonService = LocalJsonService();
  Future<OwnedGames>? _ownedGamesFuture;
  Future<Set<String>>? _playerTagsFuture;
  Future<List<JsonGameList>>? _similarGamesFuture;
  late Future<List<JsonGameList>> futureJsonGames;

  List<String> genre = [];

  @override
   void initState() {
    super.initState();
    _ownedGamesFuture = steamAPI.GetOwnedGames(widget.steamID);
    futureJsonGames = localJsonService.loadGames();

    _playerTagsFuture = _ownedGamesFuture!.then((ownedGames) {
      return _fetchGameTags(ownedGames);
    });

    _similarGamesFuture = _playerTagsFuture!.then((tags) {
      return futureJsonGames.then((jsonGames) {
        var params = {
          'jsonGames': jsonGames.map((game) => {
            'appid': game.appid,
            'name': game.name,
            'tags': game.tags,
          }).toList(),
          'playerTags': tags.toList(),
        };
        return compute(_findSimilarGames, params);
      });
    });
  }

  Future<Set<String>> _fetchGameTags(OwnedGames ownedGames) async {
  Set<String> tags = {};
  for (var game in ownedGames.games) {
    try {
      GameGenre gameInfo = await steamSpyAPI.fetchGameInfo(game.appid);
      tags.addAll(gameInfo.tags.keys);
    } catch (e) {
      print('Error fetching tags for game ${game.appid}: $e');
    }
  }
  return tags;
}

@override
void dispose() {
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<JsonGameList>>(
        future: _similarGamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No similar games found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var game = snapshot.data![index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    title: Text(
                      game.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text('Tags: ${game.tags.keys.join(', ')}'),
                        SizedBox(height: 5),
                        Text(
                          'Similarity: ${game.similarityIndex.toStringAsFixed(10)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}