import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key,});


  @override
  State<TestPage> createState() => _TestPageState();
}
class GameGenre {
  final int appid;
  final String name;
  final String genre;

  GameGenre({required this.appid, required this.name, required this.genre});

  factory GameGenre.fromJson(Map<String, dynamic> json) {
    return GameGenre(
      appid: json['appid'] as int,
      name: json['name'] as String,
      genre: json['genre'] as String,
    );
  }
}

List<GameGenre> parseGames(String jsonString) {
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  List<GameGenre> games = [];

  jsonMap.forEach((key, value) {
    games.add(GameGenre.fromJson(value));
  });

  return games;
}

class GameListService {
  Future<List<GameGenre>> loadGames() async {
    final jsonString = await rootBundle.loadString('assets/steam_games.json');
    return compute(parseGames, jsonString);
  }
}



class _TestPageState extends State<TestPage> {
  late Future<List<GameGenre>> futureGames;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureGames = GameListService().loadGames();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: FutureBuilder<List<GameGenre>>(
        future: futureGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found'));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return ListTile(
                  title: Text(game.name),
                  subtitle: Text('Genre: ${game.genre}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}