// Imports
import 'package:flutter/material.dart';
import 'package:friends_takeout/screens/homeScreen.dart';
import 'package:friends_takeout/screens/lobby.dart';
import 'package:friends_takeout/screens/loginScreen.dart';
import 'package:friends_takeout/screens/registerScreen.dart';
import 'package:friends_takeout/constants.dart';
import 'package:friends_takeout/screens/resultScreen.dart';
import 'package:friends_takeout/screens/votingScreen.dart';

void main() => runApp(FriendsTakeout());

class FriendsTakeout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friends Takeout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: kDarkBlue,
      ),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        LobbyScreen.id: (context) => LobbyScreen(),
        VotingScreen.id: (context) => VotingScreen(groupID: ""),
        ResultScreen.id: (context) => ResultScreen(groupID: "", restrauntList: null),
      },
    );
  }
}