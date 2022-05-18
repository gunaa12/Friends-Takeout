// Imports
import 'package:flutter/material.dart';
import 'package:friends_takeout/components/button.dart';
import 'package:friends_takeout/constants.dart';
import 'package:friends_takeout/screens/loginScreen.dart';
import 'package:friends_takeout/screens/registerScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:friends_takeout/firebase_options.dart';


class HomeScreen extends StatefulWidget {
  static const String id = "home_screen_id";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
                Text(
                  'Friends Takeout',
                  style: TextStyle(
                    fontFamily: 'Audiowide',
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: kGreen,
                  ),
                ),
                SizedBox(
                  height: 125,
                ),
                Hero(
                  tag: 'LoginButton',
                  child: Button(
                    content: Text('Login'),
                    color: kLightOrange,
                    onPress: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    }
                  ),
                ),
                Hero(
                  tag: 'RegisterButton',
                  child: Button(
                      content: Text('Register'),
                      color: kDarkOrange,
                      onPress: () {
                        Navigator.pushNamed(context, RegisterScreen.id);
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
