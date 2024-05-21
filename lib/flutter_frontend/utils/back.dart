import 'dart:math' as math; // Import math to use math.pi for rotation
import 'package:flutter/material.dart';

class IDCardBackWidget extends StatelessWidget {
  final String lastName = 'ABDENNOUR';
  final String firstName = 'GUESSOUM';
  final String mrzCode = 'IDDZA4076406573くくくくくくくくくくくくくくく\n9810123M3311064DZAくくくくくくくくくくくく0\nGUESSOUM<<ABDENNOURくくくくくくくくくくく';
  final String yearOfBirth = '1998';

  const IDCardBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 583.2, // CR80 card size in points
      height: 367.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/back.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 110, // Changed from right to left
              top: 288,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi), // Mirrors the widget horizontally
                child: Transform.rotate(
                  angle: math.pi, // Rotates the widget 180 degrees
                  child: Text(lastName, style: const TextStyle(                      color: Colors.black,
                       fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Positioned(
              left: 70, // Changed from right to left
              top: 325,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi), // Mirrors the widget horizontally
                child: Transform.rotate(
                  angle: math.pi, // Rotates the widget 180 degrees
                  child: Text(firstName, style: const TextStyle(                      color: Colors.black,
                      fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Positioned(
              left: 208, // Changed from right to left
              top: 223,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi), // Mirrors the widget horizontally
                child: Transform.rotate(
                  angle: math.pi, // Rotates the widget 180 degrees
                  child: Text(yearOfBirth, style: const TextStyle(                      color: Colors.black,
                      fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Positioned(
              left: 20, // Changed from right to left
              top: 20,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi), // Mirrors the widget horizontally
                child: Transform.rotate(
                  angle: math.pi, // Rotates the widget 180 degrees
                  child: Text(
                    mrzCode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2, // Adjust the value to control the spacing
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
