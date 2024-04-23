import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

class HomeScreenPage extends StatefulWidget {
  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
{
  @override
  Widget build(BuildContext context) {
   return Center(
      child: Text('Home'),
    );
  }
  
}

