import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.5,
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 136, 136, 136),
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
                SizedBox(height: 20,),
                Text(
                  "Name",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
