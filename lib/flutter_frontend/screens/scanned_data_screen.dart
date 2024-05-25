import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/jpeg2000_converter.dart';
import '../utils/mrtd_data.dart';
import 'voter_profile_screen.dart';


class scannedDataScreen extends StatefulWidget {
  final MrtdData? mrtdData;
  final Uint8List? rawImageData;
  final Uint8List? rawHandSignatureData;

  final bool isVotingStarted; // Add this line


  scannedDataScreen({

    this.mrtdData,
    this.rawImageData,
    this.rawHandSignatureData,
    this.isVotingStarted = false,
  });
  @override
  _scannedDataScreenState createState() => _scannedDataScreenState();
}

class _scannedDataScreenState extends State<scannedDataScreen> {
  Uint8List? jpegImage;
  Uint8List? jp2000Image;


  @override
  void initState() {
    super.initState();
    tryDisplayingJpg();
  }

  Widget _makeMrtdDataWidget({
    required String? header,
    required String? dataText,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(header ?? ""),
      onLongPress: () => Clipboard.setData(ClipboardData(text: dataText ?? "Null")),
      subtitle: SelectableText(dataText ?? "Null", textAlign: TextAlign.left),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: dataText ?? "Null"));
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Copied")));
        },
      ),
    );
  }

  List<Widget> _mrtdDataWidgets() {
    List<Widget> list = [];


    if (widget.mrtdData?.dg1 != null) {
      list.add(_makeMrtdDataWidget(
          header: null,
          dataText: formatMRZ(widget.mrtdData!.dg1!.mrz)));
    }


    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'INTAKHIB',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: Column(
            children: [
              Text(
                'NFC scanned DATA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              if (jpegImage != null || jp2000Image != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Image",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              if (jpegImage != null)
                Column(
                  children: [
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        jpegImage!,
                        errorBuilder: (context, error, stackTrace) => SizedBox(),
                      ),
                    ),
                  ],
                ),
              if (jp2000Image != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        jp2000Image!,
                        errorBuilder: (context, error, stackTrace) => SizedBox(),
                      ),
                    ),
                  ],
                ),
              if (widget.rawHandSignatureData != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Signature",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        widget.rawHandSignatureData!,
                        errorBuilder: (context, error, stackTrace) => SizedBox(),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: _mrtdDataWidgets(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoterProfileScreen(
                          mrtdData: widget.mrtdData!,
                          rawHandSignatureData: widget.rawHandSignatureData, // Ensure this is not null
                        ),
                      ),
                    );
                  },
                  child: Text('Confirm'), // overflow pixel error
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void tryDisplayingJpg() {
    try {
      jpegImage = widget.rawImageData;
      setState(() {});
    } catch (e) {
      jpegImage = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Image is not in jpg format, trying jpeg2000")));
    }
  }

  void tryDisplayingJp2() async {
    try {
      jp2000Image = await decodeImage(widget.rawImageData!, context);
      setState(() {});
    } catch (e) {
      jpegImage = null;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image is not in jpeg2000")));
    }
  }
}