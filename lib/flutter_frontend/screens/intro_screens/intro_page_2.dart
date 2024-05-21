import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class introPage_2 extends StatelessWidget {
  const introPage_2({Key? key}) : super(key: key);

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
              'Authentification NFC',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: betweenElementsPadding),
            Text(
              'Authentifier vous en toute sécurité grace a votre piece d\'identité nationale via la technologie NFC.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Center(
              child: Lottie.network(
                'https://lottie.host/8cffedea-5cd7-4d42-9f85-9f269264e6f8/l4eaaQE8Sp.json',
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
