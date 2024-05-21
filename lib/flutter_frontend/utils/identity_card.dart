import 'dart:math';
import 'package:flutter/material.dart';

import 'back.dart'; // Assuming this is your back widget
import 'front.dart'; // Assuming this is your front widget

class IDCard extends StatefulWidget {
  const IDCard({super.key});

  @override
  _IDCardState createState() => _IDCardState();
}

class _IDCardState extends State<IDCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final angle = _controller.value * pi;
          // Adjust the angle for a smoother transition and perspective.
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // add perspective
            ..rotateX(angle);

          // Toggle the child widget at the half rotation point.
          if (angle >= pi / 2) {
            transform.rotateX(pi); // complete the flip
          }

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle >= pi / 2 ? IDCardBackWidget() : IDCardFrontWidget(),
          );
        },
      ),
    );
  }
}
