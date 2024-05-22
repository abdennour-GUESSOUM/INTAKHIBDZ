import 'package:IntakhibDZ/blockchain_back/blockchain/blockchain_authentification.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blockchain_back/blockchain/blockachain.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkKey(context));
  }

  void _checkKey(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? key = prefs.getString('key');
    String? contract = prefs.getString('contract');
    String? second_contract = prefs.getString('second_contract');

    print([key,contract]);

    Future.delayed(Duration(seconds: 2), () async {
      if (contract == null || second_contract == null){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BlockchainAuthentification(documentNumber: '')),
                (Route<dynamic> route) => false,
          );
        });
      } else if (key == null){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BlockchainAuthentification(documentNumber: '')),
                (Route<dynamic> route) => false,
          );
        });
      } else if (await Blockchain().check() == false) {
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NoBlockChainScreen()),
                (Route<dynamic> route) => true,
          );
        });
      } else {
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false,
          );
        });
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFFd75dfd),
                  Color(0xFF675bd4),
                ],
              )
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    'assets/vote.png'
                  ),
                ),
                SizedBox(height: 25.0),
                Text(
                  "Vote4Valadiene",
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
                SizedBox(height: 25.0),
              ],
            ),
         ),
        ),
      ),
    );
  }
}

class NoBlockChainScreen extends StatefulWidget {
  @override
  _NoBlockChainScreenState createState() => _NoBlockChainScreenState();
}


class _NoBlockChainScreenState extends State<NoBlockChainScreen> {

  Blockchain blockchain = Blockchain();

  void _checkConnection(AnimationController anim) async{
    anim.forward();
    Future.delayed(Duration(seconds: 3), () async {
      if (await blockchain.check() == true){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        print("No Connection");
        anim.reset();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFFd75dfd),
                  Color(0xFF675bd4),
                ],
              )
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                      'assets/no-signal.png'
                  ),
                ),
                SizedBox(height: 25.0),
                Text(
                  "No Blockchain connection",
                  style: TextStyle(fontSize: 40, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25.0),
                Container(
                  width: 200,
                  child: NiceButtons(
                    stretch: true,
                    gradientOrientation: GradientOrientation.Horizontal,
                    onTap: (AnimationController controller) async {
                      _checkConnection(controller);
                    },
                    child: Text(
                      "Retry",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}