import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Function onPressed;

  CustomBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Colors.green,
      ), // Replace with your desired icon
      onPressed: () => onPressed(),
      tooltip: 'Back',
    );
  }
}
