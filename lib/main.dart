import 'package:INTAKHIB/firebase/authenticate_user/user_authenticated_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase/authenticate_user/authenticate_user_page.dart';
import 'firebase_options.dart';
import 'flutter_frontend/screens/intro_screens/infographic.dart';
import 'flutter_frontend/screens/mrz_nfc_scan_screen.dart';
import 'flutter_frontend/screens/mrz_nfc_scan_screen.dart';
import 'flutter_frontend/themes/dark_theme.dart';
import 'flutter_frontend/themes/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      title: 'INTAKHIB',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: seenOnboarding ? InfographicScreen() : MRZNFCScan.MRZNFCScanScreen(),
      debugShowCheckedModeBanner: false,

    );
  }
}


