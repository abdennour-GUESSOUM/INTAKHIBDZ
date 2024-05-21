import 'package:IntakhibDZ/flutter_frontend/screens/mrz_nfc_scan_screen.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/scanned_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blockchain_back/blockchain/blockchain_authentification.dart';
import 'flutter_frontend/screens/onboarding_screen.dart';
import 'flutter_frontend/themes/dark_theme.dart';
import 'flutter_frontend/themes/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? seenOnboarding = prefs.getBool('seenOnboarding');

  runApp(MyApp(seenOnboarding: seenOnboarding ?? false));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({Key? key, required this.seenOnboarding}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INTAKHIBDZ',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: seenOnboarding ? BlockchainAuthentification(documentNumber: '0987654321',) : OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
