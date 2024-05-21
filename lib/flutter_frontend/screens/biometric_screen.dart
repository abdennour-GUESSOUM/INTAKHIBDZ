import 'package:IntakhibDZ/flutter_frontend/screens/mrz_nfc_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({Key? key}) : super(key: key);

  @override
  _BiometricScreen createState() => _BiometricScreen();
}

class _BiometricScreen extends State<BiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Please authenticate';
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authentification...';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'veuiller placer votre pouce sur le capteur d\'empreinte',
      );
      setState(() {
        _authorized = authenticated ? 'Succées' : 'réessayer';
      });
      if (authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MRZNFCScan.MRZNFCScanScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _authorized = 'Authentication Error: $e';
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double edgePadding = 32.0;
    const double betweenElementsPadding = 24.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'INTAKHIBDZ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          centerTitle: true,
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
                    'Biometric authentification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'almost done.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: betweenElementsPadding * 2),
                  Text(
                    'Press the button to authenticate.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: edgePadding),
                  Center(
                    child: Lottie.asset(
                      'assets/fingerprint.json',
                      height: 100,
                    ),
                  ),
                  SizedBox(height: edgePadding * 2),
                  Center(
                    child: Text(
                      _authorized,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                  onPressed: _isAuthenticating ? null : _authenticate,
                  child: _isAuthenticating
                      ? CircularProgressIndicator()
                      : Text('Scan fingerprint'),
                ),
              ),
            ),
            SizedBox(height: edgePadding),
          ],
        ),
      ),
    );
  }
}
