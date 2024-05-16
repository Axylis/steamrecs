
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:skripsi_finals/pages/homeScreenPage.dart';
import 'package:skripsi_finals/pages/recommender.dart';
import 'package:skripsi_finals/homescreen.dart';

class RecentResultsPage extends StatefulWidget {
  const RecentResultsPage({super.key, required this.steamID});

  final String steamID;

  @override
  State<RecentResultsPage> createState() => _RecentResultsPageState();
}

class OwnedGamesDetail
{
  String? genres;
  // Add more fields as needed

  OwnedGamesDetail({required this.genres});
  

  factory OwnedGamesDetail.fromJson(Map<String,dynamic> json) {
    return OwnedGamesDetail(
      genres: ['genre'] as String,
      // Parse other fields here
    );
  }
}

class GameListWidget extends StatelessWidget {
  late List<OwnedGamesDetail> genre;

  GameListWidget({required this.genre});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: genre.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${genre[index].genres}'),
          // Add more fields here if needed
        );
      },
    );
  }
}


class _RecentResultsPageState extends State<RecentResultsPage> {

  final List<OwnedGamesDetail> _detail = [];
  String genre = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchGenresForGames();
  }

  Future<void> _fetchGenresForGames() async {
      final response = await http.get(Uri.parse('https://steamspy.com/api.php?request=appdetails&appid=730'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState((){
          genre = jsonData['genre'];
        });
      } else {
        throw Exception('Failed to load genres for game ${genre.length}');
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
      body: genre.isNotEmpty
          ? Text('$genre')
          : GameListWidget( genre: _detail,) 
    );
  }
}