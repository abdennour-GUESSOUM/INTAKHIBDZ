import 'dart:ui';
import 'package:flutter/material.dart';


Widget glassmorphicContainer({
  required BuildContext context, // Add context as a required parameter
  BoxDecoration? decoration,
  required Widget child,
  double? height,
  double? width,
}) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Container(
            decoration: decoration ?? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  spreadRadius: 1,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                )
              ],
            ),
            height: height,
            width: width,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}


