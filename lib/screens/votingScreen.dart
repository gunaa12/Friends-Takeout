// Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:friends_takeout/components/button.dart';
import 'package:friends_takeout/components/button.dart';
import 'package:friends_takeout/screens/resultScreen.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:friends_takeout/constants.dart';


class VotingScreen extends StatefulWidget {
  static const String id = "voting_screen_id";
  String groupID;

  VotingScreen({required this.groupID});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  var _data;
  var _accumulatedVotes;

  var _votes = List<int?>.filled(100, 0);

  late FirebaseFirestore _db;

  @override
  void initState() {
    _db = FirebaseFirestore.instance;
    _data = makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      body: SafeArea(
        child: Container(
          child: FutureBuilder(
            future: _data,
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.hasData) {
                var list = snapshot.data!["results"];
                return Column(
                  children: [
                    SizedBox(height: 10,),
                    Text(
                      "Nearby Restraunts",
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          if ((list[index]["business_status"] != "OPERATIONAL")) {
                            return SizedBox(height: 0,);
                          }
                          String priceString = "\$";
                          String inBetweenSpace = "      ";
                          switch (list[index]["price_level"]) {
                            case 2:
                              priceString = "\$\$";
                              inBetweenSpace = "     ";
                              break;
                            case 3:
                              priceString = "\$\$\$";
                              inBetweenSpace = "    ";
                              break;
                            case 4:
                              priceString = "\$\$\$\$";
                              inBetweenSpace = "   ";
                              break;
                            case 5:
                              priceString = "\$\$\$\$\$";
                              inBetweenSpace = "  ";
                              break;
                          }
                          String rating = "${list[index]["rating"]} / 5.0";
                          return SafeArea(
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Button(
                                color: checkColor(index),
                                borderRadius: 15.0,
                                verticalPadding: 10.0,
                                content: Container(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage: NetworkImage(
                                              "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${list[index]["photos"][0]["photo_reference"]}&key=AIzaSyAFnvBZYYEq1vn_1MOd_TOVzWkfglCb8t8",
                                            ),
                                          ),
                                        ),
                                        flex: 1,
                                      ),
                                      SizedBox(width: 20,),
                                      Flexible(
                                        flex: 4,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                list[index]["name"],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                priceString + inBetweenSpace +
                                                    rating +
                                                    "  from ${list[index]["user_ratings_total"]} users.",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                list[index]["vicinity"],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPress: () {
                                  if (_votes[index] == -1)
                                    _votes[index] = 0;
                                  else if (_votes[index] == 0)
                                    _votes[index] = 1;
                                  else
                                    _votes[index] = -1;
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    Button(
                      content: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      color: kLightBlue,
                      onPress: () {
                        update(list);
                      }
                    )
                  ],
                );
              }
              else {
                return Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: 30,
                    ),
                  ),
                );
              }
            }
          ),
        ),
      ),
    );
  }

  void update(var list) async {
    var snapshot = await _db.collection("groups").doc(widget.groupID).get();
    try {
      var newList = List<int>.filled(_votes.length, 0);
      for (int index = 0; index < newList.length; index++) {
        newList[index] = (_votes[index]! + snapshot.data()!["accumulatedVotes"][index]) as int;
      }
      _db.collection("groups").doc(widget.groupID).update({
        "accumulatedVotes": newList,
        "finishedVoting": snapshot.data()!["finishedVoting"] + 1,
      });
    } catch(e) {
      _db.collection("groups").doc(widget.groupID).update({
        "accumulatedVotes": _votes,
        "finishedVoting": snapshot.data()!["finishedVoting"] + 1,
      });
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(groupID: widget.groupID, restrauntList: list)));
  }

  Future<Map<String, dynamic>> makeRequest() async {
    final Location location = Location();
    LocationData locationData = await location.getLocation();
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAFnvBZYYEq1vn_1MOd_TOVzWkfglCb8t8&location=${locationData.latitude},${locationData.longitude}&radius=5000&type=restaurant';
    var response = await http.get(Uri.parse(url));
    print('HTTP Status Code: ${response.statusCode}!');
    Map<String, dynamic> data = json.decode(response.body);
    _votes = List<int>.filled(data["results"].length, 0);
    return data;
  }

  Color checkColor(int index) {
    if (_votes[index] == 0) {
      return kLightOrange;
    }
    else if (_votes[index] == -1) {
      return kDarkOrange;
    }
    else {
      return kGreen;
    }
  }
}