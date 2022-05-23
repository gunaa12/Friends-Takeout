// Imports
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:friends_takeout/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_takeout/screens/homeScreen.dart';
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
  int _numOfMembers = 0;
  var _users = List<dynamic>.filled(1, "");
  bool _inAGroup = false;
  final _groupIDTextBoxController = TextEditingController();

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
                            style: kHeaderFontStyle,
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
                        controller: _groupIDTextBoxController,
                        onChanged: (String text) {
                          setState(() {});
                          if (_users.contains((FirebaseAuth.instance.currentUser?.email ?? ""))) {
                            _users.remove(FirebaseAuth.instance.currentUser?.email ?? "");
                            _numOfMembers--;
                            if (_numOfMembers == 0) {
                              _db.collection('groups').doc(_groupID).delete();
                            }
                            else {
                              _db.collection('groups').doc(_groupID).update({
                                "users": _users,
                                "numOfMembers": _numOfMembers,
                              });
                            }
                          }
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
                        content: Text('Join Group'),
                        color: kLightOrange,
                        onPress: () {
                          setState(() {});
                          if ((_numOfMembers > 0) && (!_users.contains(FirebaseAuth.instance.currentUser?.email ?? ""))) {
                            _inAGroup = true;
                            _users.add(FirebaseAuth.instance.currentUser?.email ?? "");
                            _numOfMembers++;
                            _db.collection('groups').doc(_groupID).set({
                              "id": _groupID,
                              "numOfMembers": _numOfMembers,
                              "users": _users,
                              "start": false,
                              "finishedVoting": 0,
                            });
                          }
                        }
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Button(
                        content: Text('Create Group'),
                        color: kLightOrange,
                        onPress: () {
                          setState(() {});
                          if (_users.contains((FirebaseAuth.instance.currentUser?.email ?? ""))) {
                            _users.remove(FirebaseAuth.instance.currentUser?.email ?? "");
                            _numOfMembers--;
                            if (_numOfMembers == 0) {
                              _db.collection('groups').doc(_groupID).delete();
                            }
                            else {
                              _db.collection('groups').doc(_groupID).update({
                                "users": _users,
                                "numOfMembers": _numOfMembers,
                              });
                            }
                          }
                          _groupID = createGroupCode(6);
                          _groupIDTextBoxController.text = _groupID;
                          _users = List<dynamic>.filled(1, (FirebaseAuth.instance.currentUser?.email ?? ""));
                          _numOfMembers = 1;
                          _db.collection('groups').doc(_groupID).set({
                            "id": _groupID,
                            "users": _users,
                            "numOfMembers": _numOfMembers,
                            "start": false,
                            "finishedVoting": 0,
                          });
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
                            Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.id, (Route<dynamic> route) => false);
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
                  _users = document["users"];
                  _numOfMembers = document["numOfMembers"];
                  if (_numOfMembers == 0) return kEmptyBox;
                  else {
                    String toDisplay = "Users:";
                    for (var item in _users) toDisplay += ("\n" + (item as String));
                    return Center(
                      child: Text(
                        toDisplay,
                        textAlign: TextAlign.center,
                        style: kHeaderFontStyle,
                      ),
                    );
                  }
                }
                else return kEmptyBox;
              },
            );
          }
          else {
            return kEmptyBox;
          }
        }
    );
  }

  void onStart() {
    setState(() {});
    if ((_inAGroup) && (_numOfMembers >= kNumOfPeopleToStart)) {
      _db.collection('groups').doc(_groupID).update({
        "start": true,
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => VotingScreen(groupID: _groupID)));
    }
  }

  String createGroupCode(int size) {
    const _chars = '1234567890';
    Random _rnd = Random();
    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String randomString = getRandomString(size);
    return randomString;
  }

  @override
  void dispose() {
    super.dispose();
  }
}