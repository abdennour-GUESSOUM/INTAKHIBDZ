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
              'Bienvenue sur IntakhibDZ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: betweenElementsPadding),
            Text(
              'IntakhibDZ est une application de vote presidentiel nationale pour les citoyens Algeriens.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            // Your Lottie asset
            Center(
              child: Lottie.network(
                'https://lottie.host/f53e532c-ad89-47df-a701-bb122a5c84de/6qQTFxX9Y3.json',
                height: 400,

              ),
            ),
            // Add more padding at the bottom if needed
            const SizedBox(height: edgePadding * 2),
          ],
        ),
      ),
    );
  }
}
