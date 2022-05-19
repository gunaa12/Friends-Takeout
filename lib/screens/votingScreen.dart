// Imports
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class VotingScreen extends StatefulWidget {
  static const String id = "voting_screen_id";

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  var _data;

  @override
  void initState() {
    _data = makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("${_data}");
                }
                else {
                  return Text("Still Loading!");
                }
              }
            ),
        ),
      ),
    );
  }

  Future<List> makeRequest() async {
    final Location location = Location();
    LocationData locationData = await location.getLocation();
    print("Location: ${locationData.latitude}, ${locationData.longitude}");
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAFnvBZYYEq1vn_1MOd_TOVzWkfglCb8t8&location=${locationData.latitude},${locationData.longitude}&radius=5000&type=restaurant';
    var response = await http.get(Uri.parse(url));
    print('HTTP Status Code: ${response.statusCode}!');
    print(response.body);
    List<dynamic> data = json.decode(response.body);
    return data;
  }
}