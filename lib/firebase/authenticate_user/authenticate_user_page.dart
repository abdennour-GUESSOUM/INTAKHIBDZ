import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import '../common/capture_face_view.dart';
import '../common/snack_bars.dart';
import '../models/user.dart';
import 'scanning_animation/animated_view.dart';
import 'user_authenticated_page.dart';

class AuthenticateUserPage extends StatefulWidget {
  const AuthenticateUserPage({super.key, required documentNumber});

  @override
  State<AuthenticateUserPage> createState() => _AuthenticateUserPageState();
}

class _AuthenticateUserPageState extends State<AuthenticateUserPage> {
  final image1 = regula.MatchFacesImage();
  final image2 = regula.MatchFacesImage();

  bool canAuthenticate = false;
  bool faceMatched = false;
  bool isMatching = false;

  String similarity = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text('INTAKHIB', style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                CaptureFaceView(
                  onImageCaptured: (imageBytes) {
                    image1.bitmap = base64Encode(imageBytes);
                    image1.imageType = regula.ImageType.PRINTED;

                    setState(() {
                      canAuthenticate = true;
                    });
                  },
                ),
                if (isMatching)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 102),
                      child: AnimatedView(),
                    ),
                  ),
              ],
            ),
            if (canAuthenticate)
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMatching = true;
                      });
                      FirebaseFirestore.instance
                          .collection('users')
                          .get()
                          .then((snap) async {
                        if (snap.docs.isNotEmpty) {
                          for (var doc in snap.docs) {
                            final user = User.fromJson(doc.data());

                            image2.bitmap = user.image;
                            image2.imageType = regula.ImageType.PRINTED;

                            var request = regula.MatchFacesRequest();
                            request.images = [image1, image2];

                            var value = await regula.FaceSDK.matchFaces(
                                jsonEncode(request));
                            var response = regula.MatchFacesResponse.fromJson(
                                json.decode(value));

                            var str = await regula.FaceSDK
                                .matchFacesSimilarityThresholdSplit(
                                jsonEncode(response!.results), 0.75);

                            var split = regula.MatchFacesSimilarityThresholdSplit
                                .fromJson(json.decode(str));

                            similarity = split!.matchedFaces.length > 0
                                ? (split.matchedFaces[0]!.similarity! * 100)
                                .toStringAsFixed(2)
                                : "error";

                            if (similarity != 'error' &&
                                double.parse(similarity) > 90.00) {
                              faceMatched = true;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserAuthenticatedPage(name: user.name),
                                ),
                              );
                              break;
                            }
                          }

                          setState(() {
                            isMatching = false;
                          });

                          if (!faceMatched) {
                            errorSnackBar(context, 'Not eligible for voting ');
                          }
                        } else {
                          errorSnackBar(context, 'Sorry retry');
                        }
                      });
                    },
                    child: Text('Authenticate'),
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
            SizedBox()
          ],
        ),
      ),



    );
  }
}
