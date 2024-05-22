import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class introPage_1 extends StatelessWidget {
  const introPage_1({Key? key}) : super(key: key);

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
              'Welcome',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: betweenElementsPadding),
            Text(
              'INTAKHIB is an algerian E-voting Dapp.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: edgePadding * 3),
            Center(
              child: Lottie.asset(
                "assets/intro1.json",
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
