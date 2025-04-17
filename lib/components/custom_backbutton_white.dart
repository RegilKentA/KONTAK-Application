import 'package:flutter/material.dart';

class CustomBackButtonWhite extends StatelessWidget {
  final Function onPressed;

  CustomBackButtonWhite({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Colors.white,
      ), // Replace with your desired icon
      onPressed: () => onPressed(),
      tooltip: 'Back',
    );
  }
}
