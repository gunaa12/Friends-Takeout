import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:friends_takeout/components/button.dart';
import 'package:friends_takeout/components/cardButton.dart';
import 'package:friends_takeout/constants.dart';
import 'package:friends_takeout/screens/lobby.dart';
// import 'package:url_launcher/url_launcher.dart';


class ResultScreen extends StatefulWidget {
  static const String id = "result_screen_id";
  String groupID;
  var restrauntList;

  ResultScreen({required this.groupID, required this.restrauntList});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late FirebaseFirestore _db;

  @override
  void initState() {
    _db = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _db.collection('groups').doc(widget.groupID).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!["finishedVoting"] == snapshot.data!["numOfMembers"]) {
            int displayIndex = findWinner(widget.restrauntList, snapshot.data!["accumulatedVotes"]);
            String priceString = "\$";
            switch (widget.restrauntList[displayIndex]["price_level"]) {
              case 2:
                priceString = "\$\$";
                break;
              case 3:
                priceString = "\$\$\$";
                break;
              case 4:
                priceString = "\$\$\$\$";
                break;
              case 5:
                priceString = "\$\$\$\$\$";
                break;
            }
            String rating = "${widget.restrauntList[displayIndex]["rating"]} / 5.0";
            return Column(
              children: [
                SizedBox(height: 20,),
                Text(
                  "Results",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
                CardButton(
                  content: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30,),
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(
                            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${widget.restrauntList[displayIndex]["photos"][0]["photo_reference"]}&key=AIzaSyAFnvBZYYEq1vn_1MOd_TOVzWkfglCb8t8",
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text(
                          "${widget.restrauntList[displayIndex]["name"]}",
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontFamily: 'Nunito'
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Ratings: ${rating}",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Price: ${priceString}",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Address: ${widget.restrauntList[displayIndex]["vicinity"]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10,),
                        // RichText(
                        //   text: TextSpan(
                        //     children: [
                        //       TextSpan(
                        //         text: "Maps",
                        //         recognizer: TapGestureRecognizer()..onTap =  () async {
                        //           var url = "http://www.google.com/maps/place/${widget.restrauntList[displayIndex]["geometry"]["location"]["lat"]},${widget.restrauntList[displayIndex]["geometry"]["location"]["lng"]}";
                        //           if (await canLaunch(url)) {
                        //             await launch(url);
                        //           } else {
                        //             throw 'Could not launch $url';
                        //           }
                        //         }
                        //       ),
                        //     ]
                        //   )
                        // ),
                        SizedBox(height: 30,),
                      ],
                    ),
                  ),
                  color: kLightOrange,
                  onPress: () {},
                ),
                Button(
                  content: Text("Done!"),
                  color: kGreen,
                  onPress: () {
                    if (snapshot.data!["numOfMembers"] == 1) {
                      _db.collection("groups").doc(widget.groupID).delete();
                    }
                    else {
                      String newUserList = snapshot.data!["users"].replaceAll(((FirebaseAuth.instance.currentUser?.email ?? "") + "; "), "");
                      _db.collection("groups").doc(widget.groupID).update({
                        "numOfMembers": snapshot.data!["numOfMembers"] - 1,
                        "users": newUserList,
                      });
                    }
                    Navigator.pushNamed(context, LobbyScreen.id);
                  },
                ),
              ],
            );
          }
          else {
            return loading();
          }
        }
        else {
          return loading();
        }
      }
    );
  }

  Widget loading() {
    return Scaffold(
      backgroundColor: kDarkBlue,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              "Waiting for other members to finish voting...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int findWinner(var list, var accumulatedVotes) {
    int maxIndex = 0;
    int maxVotes = accumulatedVotes[0];
    for (int index = 1; index < accumulatedVotes.length; index++) {
      if (accumulatedVotes[index] > maxVotes) {
        maxIndex = index;
        maxVotes = accumulatedVotes[index];
      }
      else if (accumulatedVotes[index] == maxVotes) {
        if (list[index]["rating"] > list[maxIndex]["rating"]) {
          maxIndex = index;
        }
        else if (list[index]["rating"] == list[maxIndex]["rating"]) {
          if (list[index]["price_level"] < list[maxIndex]["price_level"]) {
            maxIndex = index;
          }
          else if ((list[index]["price_level"] < list[maxIndex]["price_level"]) &&
              (list[index]["user_ratings_total"] > list[maxIndex]["user_ratings_total"])) {
            maxIndex = index;
          }
        }
      }
    }
    return maxIndex;
  }
}
