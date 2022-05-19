import 'package:friends_takeout/constants.dart';

import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final Widget content;
  final Color color;
  final VoidCallback onPress;
  double borderRadius;
  double verticalPadding;
  double width;

  CardButton({required this.content, required this.color, required this.onPress, this.width = kDefaultButtonWidth, this.borderRadius = kDefaultButtonBorderRadius, this.verticalPadding = kVerticalPadding});

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