import 'dart:ffi';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  final String steamID;
  const ProfilePage({super.key, required this.steamID});
  State<ProfilePage> createState() => _ProfilePageState();

}
class PlayerSummary {
  final String steamId;
  final String personaName;
  final String avatarfull;
  // Add more fields as needed

  PlayerSummary({required this.steamId, required this.personaName, required this.avatarfull});

  factory PlayerSummary.fromJson(Map<String, dynamic> json) {
    return PlayerSummary(
      steamId: json['steamid'],
      personaName: json['personaname'],
      avatarfull: json['avatarfull']
      // Parse other fields here
    );
  }
}

class PlayerSummaryWidget extends StatelessWidget {
  final PlayerSummary player;

  PlayerSummaryWidget({required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(backgroundImage: NetworkImage('${player.avatarfull}'), ),
        Text(
          'Steam ID: ${player.steamId}',
          style: TextStyle(fontSize: 16, color: Color.fromARGB(251, 197, 196, 196)),
        ),
        Text(
          'Steam Name: ${player.personaName}',
          style: TextStyle(fontSize: 20, color: Color.fromARGB(251, 197, 196, 196)),
        ),
        // Add more fields here if needed
      ],
    );
  }
}


class SteamApiService {

  Future<PlayerSummary> getPlayerSummaries(String steamIds) async {
    final response = await http.get(Uri.parse('https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=EBB0C29D061E421500F4401B108C3C4A&steamids=$steamIds/0'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['response']['players'];
      return PlayerSummary.fromJson(data.first);
    } else {
      throw Exception('Failed to load player summaries');
    }
  }
}

class _ProfilePageState extends State<ProfilePage> {

  PlayerSummary? _players;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPlayerSummaries();
  }

  Future<void> _fetchPlayerSummaries() async {
    try {
      final apiService = SteamApiService();
      final players = await apiService.getPlayerSummaries(widget.steamID);
      setState(() {
        _players = players;
      });
    } catch (e) {
      print('Error fetching player summaries: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _players != null
          ? Center(
            child: Padding(
              child: Card(
                    child: PlayerSummaryWidget(player: _players!),
                    color: Color.fromARGB(253, 5, 2, 138),
                    margin: EdgeInsets.all(14),
                  ),
                  padding: EdgeInsets.all(20),
            ),
          )
          : Center(
            child: Card(
              child: Text(widget.steamID),
            ),
          )
      ); 
  }
}
