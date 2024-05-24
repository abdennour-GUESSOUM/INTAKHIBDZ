import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/snack_bars.dart';

class VerifyUserPage extends StatefulWidget {
  final String imageData;
  const VerifyUserPage({required this.imageData, super.key});

  @override
  State<VerifyUserPage> createState() => _VerifyUserPageState();
}

class _VerifyUserPageState extends State<VerifyUserPage> {
  @override
  void initState() {
    super.initState();
    verifyUser(widget.imageData);
  }

  void verifyUser(String imageData) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      bool userFound = false;

      for (var doc in snapshot.docs) {
        var userData = doc.data() as Map<String, dynamic>;
        if (userData['image'] == imageData) {
          userFound = true;
          break;
        }
      }

      Navigator.of(context).pop();

      if (userFound) {
        successSnackBar(context, 'User verified successfully , eligible for voting!');
      } else {
        errorSnackBar(context, 'User not eligible!');
      }
    } catch (e) {
      Navigator.of(context).pop();
      errorSnackBar(context, 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify User"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Verifying user, please wait...",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
