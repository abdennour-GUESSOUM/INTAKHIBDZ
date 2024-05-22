import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class introPage_3 extends StatelessWidget {
  const introPage_3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    const double edgePadding = 32.0;
    const double betweenElementsPadding = 24.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: edgePadding),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            Text(
              'Blockchain technology',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: betweenElementsPadding),
            Text(
              'Blockchain offers a robust and secure system.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: edgePadding * 3 ),
            Center(
              child: Lottie.asset(
                "assets/blockchain_intro.json",
                height: 200,
              ),
            ),
            const SizedBox(height: edgePadding * 2),
          ],
        ),
      ),
    );
  }
}

