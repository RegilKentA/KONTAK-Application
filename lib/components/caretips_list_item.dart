import 'package:flutter/material.dart';

class CaretipsListItem extends StatelessWidget {
  final String imagePath;
  final String text;
  final Function onTap;
  final double imageWidth; // Add width parameter
  final double imageHeight; // Add height parameter

  const CaretipsListItem({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.onTap,
    required this.imageHeight,
    required this.imageWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 100, // Adjust the height here
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 40),
              Image.asset(
                imagePath,
                width: imageWidth, // Use editable width
                height: imageHeight, // Use editable height
                fit: BoxFit.contain, // Adjust BoxFit as needed
              ),
              SizedBox(width: 40),
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
