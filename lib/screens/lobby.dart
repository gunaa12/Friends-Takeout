// Imports
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:friends_takeout/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_takeout/screens/votingScreen.dart';
import 'package:friends_takeout/components/button.dart';


class LobbyScreen extends StatefulWidget {
  static const String id = 'lobby_screen_id';

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}


class _LobbyScreenState extends State<LobbyScreen> {
  // Attributes
  late FirebaseAuth _auth;
  late FirebaseFirestore _db;

  String _groupID = "";
  String _users = "";
  int _numOfMembers = 0;
  bool _inAGroup = false;

  @override
  void initState() {
    _auth = FirebaseAuth.instance;
    _db = FirebaseFirestore.instance;
    getGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      body: SafeArea(
        child: Column(
          children: [
            kAppBar,
            Flexible(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 5,
                    child: getGroup(),
                  ),
                  Visibility(
                    visible: !_inAGroup,
                    child: Flexible(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "Join a group using a group code!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: 370,
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (String text) {
                          setState(() {});
                          if (_users.contains((FirebaseAuth.instance.currentUser?.email ?? ""))) {
                            _users = _users.replaceAll(((FirebaseAuth.instance.currentUser?.email ?? "") + "; "), "");
                            if (_users == "") {
                              _db.collection('groups').doc(_groupID).delete();
                            }
                            else {
                              _numOfMembers--;
                              _db.collection('groups').doc(_groupID).update({
                                "users": _users,
                                "numOfMembers": _numOfMembers,
                              });
                            }
                          }
                          _users = "";
                          _inAGroup = false;
                          _groupID = text;
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: kInputFieldDecoration.copyWith(
                          hintText: 'Enter Group ID',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Button(
                      content: Text('Join/Create Group'),
                      color: kLightOrange,
                      onPress: () {
                        setState(() {});
                        if (!_users.contains(FirebaseAuth.instance.currentUser?.email ?? "")) {
                          String newUserList = _users +
                              (FirebaseAuth.instance.currentUser?.email ?? "") + "; ";
                          _numOfMembers++;
                          _db.collection('groups').doc(_groupID).set({
                            "id": _groupID,
                            "finishedVoting": 0,
                            "start": false,
                            "users": newUserList,
                            "numOfMembers": _numOfMembers,
                          });
                        }
                        _inAGroup = true;
                      }
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Button(
                      content: Text('Start'),
                      color: kLightOrange,
                      onPress: () {onStart();},
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Divider(
                    color: kLightBlue,
                    thickness: 2,
                    endIndent: 20,
                    indent: 20,
                  ),
                  Hero(
                    tag: "logout_button",
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Button(
                        content: Text(
                          'Logout',
                        ),
                        onPress: () {
                          _auth.signOut();
                          Navigator.pop(context);
                        },
                        color: kDarkOrange,
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget getGroup() {
    return StreamBuilder(
      stream: _db.collection('groups').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot?.data!.size ?? 0,
            itemBuilder: (context, _index) {
              var document = snapshot.data!.docs[_index];
              if (document["id"] == _groupID) {
                this._users = document["users"];
                this._numOfMembers = document["numOfMembers"];
                _inAGroup = true;
                String toDisplay = "Users:\n" + _users.replaceAll("; ", "\n");
                return Center(
                  child: Text(
                    toDisplay,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                );
              }
              else {
                return SizedBox(
                  height: 0.0,
                );
              }
            },
          );
        }
        else {
          return SizedBox(
            height: 0.0,
          );
        }
      }
    );
  }

  void onStart() {
    setState(() {});
    if (_inAGroup) {
      _db.collection('groups').doc(_groupID).update({
        "start": true,
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => VotingScreen(groupID: _groupID)));
    }
  }

  String createGroupCode() {
    const _chars = '1234567890';
    Random _rnd = Random();
    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String randomString = getRandomString(6);
    return randomString;
  }
}