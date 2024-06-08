import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';


class CaptureFaceView extends StatefulWidget {
  final void Function(Uint8List) onImageCaptured;
  const CaptureFaceView({
    required this.onImageCaptured,
    super.key,
  });

  @override
  State<CaptureFaceView> createState() => _CaptureFaceViewState();
}

class _CaptureFaceViewState extends State<CaptureFaceView> {
  late final ImagePicker picker;
  File? _image;

  @override
  void initState() {
    super.initState();

    picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80),
        Text(
          'FaceID authentification',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 50),

        Text(
          'take a picture and click on the button.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 50),
        CircleAvatar(
          radius: 100,
          backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.1),
          backgroundImage: _image == null ? null : FileImage(_image!),
          child: _image == null
              ?  Center(
                  child: Lottie.asset(
                    "assets/face_auth.json",
                    height: 200,
                  ),
                )
              : null,
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              _image = null;
            });
            final pickedImage = await picker.pickImage(
              source: ImageSource.camera,
              maxHeight: 400,
              maxWidth: 400,
            );

            if (pickedImage == null) {
              return;
            }

            final imagePath = pickedImage.path;

            setState(() {
              _image = File(imagePath);
            });

            final imageBytes = _image!.readAsBytesSync();

            widget.onImageCaptured(imageBytes);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            height: 80,
            decoration:  BoxDecoration(
              gradient: RadialGradient(
                stops: [0.9, 0.65, 1],
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'take a picture',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),

      ],
    );
  }
}
