import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../firebase/authenticate_user/authenticate_user_page.dart';
import '../utils/glassmorphismContainer.dart';
import '../utils/mrtd_data.dart';

class VoterProfileScreen extends StatefulWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;
  final bool isVotingStarted;

  VoterProfileScreen({
    required this.mrtdData,
    this.rawHandSignatureData,
    this.isVotingStarted = false,
  });

  @override
  _VoterProfileScreenState createState() => _VoterProfileScreenState();
}

class _VoterProfileScreenState extends State<VoterProfileScreen> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => _showFullSizeImage(context, widget.mrtdData.dg2!.imageData!),
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: MemoryImage(widget.mrtdData.dg2!.imageData!),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _isVisible ? _profileDetails() : Container(),
            _isVisible ? _signatureSection() : Container(),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (!widget.isVotingStarted) {
                    await _saveProfile();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthenticateUserPage(),
                    ),
                  );
                },
                child: Text('Proceed'),
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
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFullSizeImage(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(imageData),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _profileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Image",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    height: 200,
                    widget.mrtdData.dg2!.imageData!,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Card(
                  child: _detailsChip('National identification number', formatDG11(widget.mrtdData.dg11!))),
              Card(
                  child: _detailsChip('First Name', widget.mrtdData.dg1!.mrz.firstName)),
              Card(
                  child: _detailsChip('Last Name', widget.mrtdData.dg1!.mrz.lastName)),
              Card(
                  child: _detailsChip('Document Number', widget.mrtdData.dg1!.mrz.documentNumber)),
              Card(child:
              _detailsChip('Date of Birth', DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfBirth))),
              Card(child:
              _detailsChip('Nationality', widget.mrtdData.dg1!.mrz.nationality)),
              Card(
                  child: _detailsChip('Expires', DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfExpiry))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signatureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Signature',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.memory(
                widget.rawHandSignatureData!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsChip(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 8),
          Text(
            textAlign: TextAlign.left,
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    var profileData = {
      'firstName': widget.mrtdData.dg1!.mrz.firstName,
      'lastName': widget.mrtdData.dg1!.mrz.lastName,
      'documentNumber': widget.mrtdData.dg1!.mrz.documentNumber,
      'dateOfBirth': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfBirth),
      'nationality': widget.mrtdData.dg1!.mrz.nationality,
      'expiryDate': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfExpiry),
      'image': base64Encode(widget.mrtdData.dg2!.imageData!), // Encoding image to base64 string
      'nationalIdentificationNumber': widget.mrtdData.dg11!.personalNumber,
    };

    // Save to Firestore
    FirebaseFirestore.instance.collection('users').add(profileData).then((docRef) {
      print("User data saved to Firestore with ID: ${docRef.id}");
      print("National identification number: ${widget.mrtdData.dg11!.personalNumber}");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthenticateUserPage(),
        ),
      );
    }).catchError((error) {
      print("Failed to save user data: $error");
    });
  }
}
