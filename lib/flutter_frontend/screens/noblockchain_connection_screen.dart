import 'package:INTAKHIB/flutter_frontend/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../blockchain_back/blockchain/blockachain.dart';


class NoBlockChainScreen extends StatefulWidget {
  @override
  _NoBlockChainScreenState createState() => _NoBlockChainScreenState();
}


class _NoBlockChainScreenState extends State<NoBlockChainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Blockchain blockchain = Blockchain();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkConnection() async {
    _controller.forward();
    Future.delayed(Duration(seconds: 3), () async {
      if (await blockchain.check() == true) {
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        print("No Connection");
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(

              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('Exception', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),

      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset(
                  'assets/no_signal.json',
                  height: 250,
                ),
                SizedBox(height: 100.0),
                Text(
                  "No Blockchain connection",
                  style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.0),
                Container(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: _checkConnection,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ), // Border color and width
                      ),
                    ),
                    child: Text(
                      "go back",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
