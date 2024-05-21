import 'package:IntakhibDZ/flutter_frontend/screens/biometric_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FaceIDScreen extends StatelessWidget {
  const FaceIDScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    const double edgePadding = 32.0;
    const double betweenElementsPadding = 24.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text('INTAKHIBDZ', style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: edgePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Text(
                    'FaceID authentification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'One step closer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: betweenElementsPadding),
                  Text(
                    'Scan your face to authenticate .',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: edgePadding * 2),
                  Center(
                    child: Lottie.asset(
                      "assets/face_auth.json",
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return BiometricScreen();
                        },
                      ),
                    );
                  },
                  child: Text('Next Step'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0,
                      ), // Border color and width
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: edgePadding), // Optional padding at the bottom
          ],
        ),
      ),
    );
  }
}
