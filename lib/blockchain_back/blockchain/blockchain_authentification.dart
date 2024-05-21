import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../flutter_frontend/screens/welcome_screen.dart';

class BlockchainAuthentification extends StatefulWidget {
  final String? documentNumber;

  BlockchainAuthentification({required this.documentNumber});

  @override
  _BlockchainAuthentificationState createState() => _BlockchainAuthentificationState();
}

class _BlockchainAuthentificationState extends State<BlockchainAuthentification> {


  final String smartContractAddress = "0x3F072216BeC7963fCd6fEdeDcB84323014466780";
  final String secondSmartContractAddress = "0xCab14A3101de74327589000F3629724AF5413481"; // Replace with your actual second contract address



  final keyController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    process(smartContractAddress, secondSmartContractAddress); // Pass both contract addresses here
  }

  void process(String addr, String secondAddr) {
    if (addr.length == 42 && secondAddr.length == 42) {
      SharedPreferences.getInstance().then((sp) {
        sp.setString("contract", addr);
        sp.setString("second_contract", secondAddr);
      });
    } else {
      print("One or both addresses are not valid");
    }
  }

  Future<void> _login() async {
    print('Starting login process...');

    String key = keyController.text;
    print('Private key entered: $key');

    if (key.length != 64) {
      print('Error: Private key format is incorrect.');
      _showAlert("Error in the Private key format");
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.2:3000/check-document'), // Update with your server address
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'documentNumber': widget.documentNumber}),
    );

    print('HTTP POST request sent to server...');

    if (response.statusCode == 200) {
      print('Server response received with status code 200.');

      final responseBody = jsonDecode(response.body);
      if (responseBody['exists']) {
        print('Document number exists. Proceeding to welcome screen...');

        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString("key", key);
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        print('Document number not found. Showing alert...');
        _showAlert("Not eligible for voting. Please try again.");
      }
    } else {
      print('Error: Server response received with status code ${response.statusCode}.');
      _showAlert("Server error. Please try again later.");
    }
  }

  void _showAlert(String message) {
    Alert(
      context: context,
      type: AlertType.error,
      title: message,
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        alertPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 1,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        descStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        animationDuration: const Duration(milliseconds: 500),
        alertElevation: 5,
        overlayColor: Colors.black54,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Retry",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          color: Theme.of(context).colorScheme.secondary,
          radius: BorderRadius.circular(10.0),
          width: 120,
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final passwordField = TextFormField(
      decoration: InputDecoration(
        labelText: 'Private key',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0),
        ),
        contentPadding: EdgeInsets.all(16.0),
      ),
      controller: keyController,
      obscureText: true,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    final loginButton = Container(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.0,
              ),
            ),
          ),
          onPressed: _login,
          child: const Text("Connect"),
        ),
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('CONNEXION ', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: ClipRRect(
        child: ListView(
          children: <Widget>[
            Center(
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: const Text(
                          "Enter your \n private key",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      Container(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/blockchain.json'),
                      ),
                      const SizedBox(height: 35.0),
                      passwordField,
                      const SizedBox(height: 50.0),
                      loginButton,
                      const SizedBox(height: 15.0),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
