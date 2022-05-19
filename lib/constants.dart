// Imports
import 'package:flutter/material.dart';

// Colors
const kDarkBlue = Color(0xFF0B132B);
const kLightBlue = Color(0xFF246A73);
const kDarkOrange = Color(0xFFFF7F11);
const kLightOrange = Color(0xFFEEA243);
const kGreen = Color(0xFF758E4F);

const double kDefaultButtonWidth = 350.0;
const double kDefaultTextFieldWidth = 375.0;
const kDefaultButtonBorderRadius = 30.0;
const kVerticalPadding = 16.0;

var logo = Image.asset('assets/images/logo.png');

const kInputFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);