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
              'Technologie Blockchain',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: betweenElementsPadding),
            Text(
              'La Blockchain offre un systeme de transparence hautement fiable et sécurisé.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            // Your Lottie asset
            Center(
              child: Lottie.network(
                'https://lottie.host/5f7f57b4-f05b-47d2-9eef-63a9d4c554c6/VqoYlfgfr0.json',
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

