// Imports
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;


class VotingScreen extends StatefulWidget {
  static const String id = "voting_screen_id";

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  @override
  Widget build(BuildContext context) {
    makeRequest();
    return Scaffold(
      body: SafeArea(
        child: Container(

        ),
      ),
    );
  }

  Future<String> makeRequest() async {
    final Location location = Location();
    LocationData locationData = await location.getLocation();
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAFnvBZYYEq1vn_1MOd_TOVzWkfglCb8t8&location=${locationData.latitude},${locationData.longitude}&radius=5000&type=restaurant';
    var response = await http.get(Uri.parse(url));
    print(response.statusCode);
    print(response.body);
    return response.body;
  }
}