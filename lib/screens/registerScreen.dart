// Imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_takeout/constants.dart';
import 'package:friends_takeout/screens/lobby.dart';
import 'package:friends_takeout/components/button.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = "register_screen_id";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late FirebaseAuth auth;
  late String _email;
  late String _password;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(tag: 'logo', child: logo),
                SizedBox(height:20),
                Container(
                  width: 375,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (String text) {
                      _email = text;
                    },
                    decoration: kInputFieldDecoration.copyWith(
                      hintText: 'Enter e-mail here',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  width: 375,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    onChanged: (String text) {
                      _password = text;
                    },
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    obscureText: true,
                    decoration: kInputFieldDecoration.copyWith(
                      hintText: 'Enter password here',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Hero(
                  tag: 'RegisterButton',
                  child: Button(
                    content: Text('Register'),
                    color: kDarkOrange,
                    onPress: () async {
                      try {
                        print(_email);
                        print(_password);
                        await auth.createUserWithEmailAndPassword(
                            email: _email, password: _password);
                        Navigator.pushNamed(context, LobbyScreen.id);
                      }
                      catch (e) {
                        print(e);
                      }
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
