// Imports
import 'package:flutter/material.dart';
import 'package:friends_takeout/constants.dart';


class Button extends StatelessWidget {
  // Attributes
  final Widget content;
  final Color color;
  final VoidCallback onPress;
  final double borderRadius;
  final double verticalPadding;
  final double width;

  // Constructor
  Button({required this.content, required this.color, required this.onPress, this.width = kDefaultButtonWidth, this.borderRadius = kDefaultButtonBorderRadius, this.verticalPadding = kVerticalPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Material(
        elevation: 5.0,
        color: this.color,
        borderRadius: BorderRadius.circular(this.borderRadius),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: width,
          child: content,
        ),
      ),
    );
  }
}