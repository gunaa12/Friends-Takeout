// Imports
import 'package:flutter/material.dart';
import 'package:friends_takeout/components/button.dart';
import 'package:friends_takeout/components/cardButton.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:friends_takeout/constants.dart';


class VotingScreen extends StatefulWidget {
  static const String id = "voting_screen_id";

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  var _data;
  var _pictureLinks;

  @override
  void initState() {
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
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      if ((list[index]["business_status"] != "OPERATIONAL") ) {
                        return SizedBox(height: 0,);
                      }
                      String priceString = "\$";
                      switch (list[index]["price_level"]) {
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
                      return SafeArea(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: CardButton(
                            color: kLightOrange,
                            borderRadius: 15.0,
                            verticalPadding: 10.0,
                            content: Container(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: CircleAvatar(
                                      child: Image.network("https://www.linguahouse.com/linguafiles/md5/d01dfa8621f83289155a3be0970fb0cb"),
                                    ),
                                    flex: 1,
                                  ),
                                  SizedBox(width: 10,),
                                  Flexible(
                                    flex: 4,
                                    child: Column(
                                        children: [
                                          Text(list[index]["name"]),
                                          Text(priceString + " * "),
                                        ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPress: () {

                            },
                          ),
                        ),
                      );
                    }
                  );
                  return Center(child: Text("${snapshot.data!["results"]}"));
                }
                else {
                  return Center(
                    child: Text("Loading..."),
                  );
                }
              }
            ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> makeRequest() async {
    final Location location = Location();
    LocationData locationData = await location.getLocation();
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAFnvBZYYEq1vn_1MOd_TOVzWkfglCb8t8&location=${locationData.latitude},${locationData.longitude}&radius=5000&type=restaurant';
    var response = await http.get(Uri.parse(url));
    print('HTTP Status Code: ${response.statusCode}!');
    Map<String, dynamic> data = json.decode(response.body);
    // _pictureLinks = List();

    return data;
  }
}