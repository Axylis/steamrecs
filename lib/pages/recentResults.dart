import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:skripsi_finals/pages/homeScreenPage.dart';
import 'package:skripsi_finals/pages/recommender.dart';
import 'package:skripsi_finals/homescreen.dart';

class RecentResultsPage extends StatefulWidget {
  const RecentResultsPage({super.key, required this.steamID});

  final String steamID;

  @override
  State<RecentResultsPage> createState() => _RecentResultsPageState();
}

class _RecentResultsPageState extends State<RecentResultsPage> {

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
        children: List.generate(10, (index) {
          return Center(
            child: Text('Item $index'),
          );
        })
      ),
    );
  }
}