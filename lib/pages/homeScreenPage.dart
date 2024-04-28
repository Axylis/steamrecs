import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:skripsi_finals/pages/Results.dart';
import 'package:skripsi_finals/pages/recommender.dart';

class HomeScreenPage extends StatefulWidget {
  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
{
  @override
  Widget build(BuildContext context) {
   return Center(
      child: Column(
        children: <Widget>[
          TextButton(
              onPressed:() {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => ResultsPage()),
                );
              },
              style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 27, 27, 27)), child: const Text('Recommend me!')
            ),
        ],)

            
   );
  }
  
}

