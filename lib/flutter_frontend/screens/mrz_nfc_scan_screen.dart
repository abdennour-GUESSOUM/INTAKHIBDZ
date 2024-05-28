import 'package:INTAKHIB/flutter_frontend/screens/voter_profile_screen.dart';
import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import '../dmrtd_lib/src/lds/df1/efdg2.dart';
import '../dmrtd_lib/src/com/nfc_provider.dart';
import '../dmrtd_lib/extensions.dart';
import '../dmrtd_lib/src/lds/df1/efdg1.dart';
import '../dmrtd_lib/src/lds/df1/efdg10.dart';
import '../dmrtd_lib/src/lds/df1/efdg11.dart';
import '../dmrtd_lib/src/lds/df1/efdg12.dart';
import '../dmrtd_lib/src/lds/df1/efdg13.dart';
import '../dmrtd_lib/src/lds/df1/efdg14.dart';
import '../dmrtd_lib/src/lds/df1/efdg15.dart';
import '../dmrtd_lib/src/lds/df1/efdg16.dart';
import '../dmrtd_lib/src/lds/df1/efdg5.dart';
import '../dmrtd_lib/src/lds/df1/efdg6.dart';
import '../dmrtd_lib/src/lds/df1/efdg7.dart';
import '../dmrtd_lib/src/lds/df1/efdg8.dart';
import '../dmrtd_lib/src/lds/df1/efdg9.dart';
import '../dmrtd_lib/src/passport.dart';
import '../dmrtd_lib/src/proto/dba_keys.dart';
import '../utils/mrtd_data.dart';

class MRZNFCScan extends StatefulWidget {
  const MRZNFCScan.MRZNFCScanScreen({super.key});

  @override
  _MRZNFCScanState createState() => _MRZNFCScanState();
}

class _MRZNFCScanState extends State<MRZNFCScan> {
  var _alertMessage = "";
  final _log = Logger("IntakhibDz.app");
  var _isNfcAvailable = false;
  var _isReading = false;
  final _mrzData = GlobalKey<FormState>();
  final _docNumber = TextEditingController();
  final _dob = TextEditingController();
  final _doe = TextEditingController();
  final NfcProvider _nfc = NfcProvider();

  late Timer _timerStateUpdater;
  final _scrollController = ScrollController();
  bool _showUserInstructions = true;

  Uint8List? rawImageData;
  Uint8List? rawHandSignatureData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _timerStateUpdater = Timer.periodic(Duration(seconds: 3), (Timer t) => _initPlatformState());
  }

  Future<void> _initPlatformState() async {
    bool isNfcAvailable;
    try {
      NfcStatus status = await NfcProvider.nfcStatus;
      isNfcAvailable = status == NfcStatus.enabled;
    } on PlatformException {
      isNfcAvailable = false;
    }

    if (!mounted) return;

    _isNfcAvailable = isNfcAvailable;
    setState(() {});
  }

  DateTime? _getDOBDate() {
    if (_dob.text.isEmpty) {
      return null;
    }
    return DateFormat.yMd().parse(_dob.text);
  }

  DateTime? _getDOEDate() {
    if (_doe.text.isEmpty) {
      return null;
    }
    return DateFormat.yMd().parse(_doe.text);
  }

  Future<String?> _pickDate(BuildContext context, DateTime firstDate, DateTime initDate, DateTime lastDate) async {
    final locale = Localizations.localeOf(context);
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: firstDate,
        initialDate: initDate,
        lastDate: lastDate,
        locale: locale);

    if (picked != null) {
      return DateFormat.yMd().format(picked);
    }
    return null;
  }

  String extractImageData(String inputHex) {
    int startIndex = inputHex.indexOf('ffd8');
    int endIndex = inputHex.indexOf('ffd9');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      String extractedImageData = inputHex.substring(
          startIndex, endIndex + 4); // Include 'FFD9' in the substring
      return extractedImageData;
    } else {
      print("FFD8 and/or FFD9 markers not found in the input hex string.");
      return inputHex;
    }
  }

  Future<void> _readMRTD() async {
    try {
      setState(() {
        _alertMessage = "Waiting for Document tag ...";
        _isReading = true;
      });

      await _nfc.connect(iosAlertMessage: "Hold your phone near Biometric Document");
      final passport = Passport(_nfc);

      setState(() {
        _alertMessage = "Reading Document ...";
      });

      _nfc.setIosAlertMessage("Trying to read EF.CardAccess ...");
      final mrtdData = MrtdData();

      try {
        mrtdData.cardAccess = await passport.readEfCardAccess();
      } on PassportError {
        // Handle error
      }

      _nfc.setIosAlertMessage("Trying to read EF.CardSecurity ...");

      try {
        mrtdData.cardSecurity = await passport.readEfCardSecurity();
      } on PassportError {
        // Handle error
      }

      _nfc.setIosAlertMessage("Initiating session ...");
      final bacKeySeed = DBAKeys(_docNumber.text, _getDOBDate()!, _getDOEDate()!);
      await passport.startSession(bacKeySeed);

      _nfc.setIosAlertMessage(formatProgressMsg("Reading EF.COM ...", 0));
      mrtdData.com = await passport.readEfCOM();

      _nfc.setIosAlertMessage(formatProgressMsg("Reading Data Groups ...", 20));

      if (mrtdData.com!.dgTags.contains(EfDG1.TAG)) {
        mrtdData.dg1 = await passport.readEfDG1();
      }

      if (mrtdData.com!.dgTags.contains(EfDG2.TAG)) {
        mrtdData.dg2 = await passport.readEfDG2();
      }

      if (mrtdData.com!.dgTags.contains(EfDG5.TAG)) {
        mrtdData.dg5 = await passport.readEfDG5();
      }

      if (mrtdData.com!.dgTags.contains(EfDG6.TAG)) {
        mrtdData.dg6 = await passport.readEfDG6();
      }

      if (mrtdData.com!.dgTags.contains(EfDG7.TAG)) {
        mrtdData.dg7 = await passport.readEfDG7();

        String? imageHex = extractImageData(mrtdData.dg7!.toBytes().hex());
        Uint8List? decodeImageHex = Uint8List.fromList(List<int>.from(hex.decode(imageHex)));
        rawHandSignatureData = decodeImageHex;
      }

      if (mrtdData.com!.dgTags.contains(EfDG8.TAG)) {
        mrtdData.dg8 = await passport.readEfDG8();
      }

      if (mrtdData.com!.dgTags.contains(EfDG9.TAG)) {
        mrtdData.dg9 = await passport.readEfDG9();
      }

      if (mrtdData.com!.dgTags.contains(EfDG10.TAG)) {
        mrtdData.dg10 = await passport.readEfDG10();
      }

      if (mrtdData.com!.dgTags.contains(EfDG11.TAG)) {
        mrtdData.dg11 = await passport.readEfDG11();
      }

      if (mrtdData.com!.dgTags.contains(EfDG12.TAG)) {
        mrtdData.dg12 = await passport.readEfDG12();
      }

      if (mrtdData.com!.dgTags.contains(EfDG13.TAG)) {
        mrtdData.dg13 = await passport.readEfDG13();
      }

      if (mrtdData.com!.dgTags.contains(EfDG14.TAG)) {
        mrtdData.dg14 = await passport.readEfDG14();
      }

      if (mrtdData.com!.dgTags.contains(EfDG15.TAG)) {
        mrtdData.dg15 = await passport.readEfDG15();
        _nfc.setIosAlertMessage(formatProgressMsg("Doing AA ...", 60));
        mrtdData.aaSig = await passport.activeAuthenticate(Uint8List(8));
      }

      if (mrtdData.com!.dgTags.contains(EfDG16.TAG)) {
        mrtdData.dg16 = await passport.readEfDG16();
      }

      _nfc.setIosAlertMessage(formatProgressMsg("Reading EF.SOD ...", 80));
      mrtdData.sod = await passport.readEfSOD();

      _alertMessage = "";

      if (mrtdData.dg2?.imageData != null) {
        rawImageData = mrtdData.dg2?.imageData;
        tryDisplayingJpg();
      }

      _scrollController.animateTo(300.0, duration: const Duration(milliseconds: 500), curve: Curves.ease);

      setState(() {});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoterProfileScreen(
            mrtdData: mrtdData,
            rawHandSignatureData: rawHandSignatureData,
          ),
        ),
      );
    } on Exception catch (e) {
      final se = e.toString().toLowerCase();
      String alertMsg = "An error has occurred while reading Document!";
      if (e is PassportError) {
        if (se.contains("security status not satisfied")) {
          alertMsg = "Failed to initiate session with passport.\nCheck input data!";
        }
        _log.error("PassportError: ${e.message}");
      } else {
        _log.error("An exception was encountered while trying to read Document: $e");
      }

      if (se.contains('timeout')) {
        alertMsg = "Timeout while waiting for Document tag";
      } else if (se.contains("tag was lost")) {
        alertMsg = "Tag was lost. Please try again!";
      } else if (se.contains("invalidated by user")) {
        alertMsg = "";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(se)));

      setState(() {
        _alertMessage = alertMsg;
      });
    } finally {
      if (_alertMessage.isNotEmpty) {
        await _nfc.disconnect(iosErrorMessage: _alertMessage);
      } else {
        await _nfc.disconnect(iosAlertMessage: formatProgressMsg("Finished", 100));
      }

      setState(() {
        _isReading = false;
      });
    }
  }

  Padding _buildMRZForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Form(
        key: _mrzData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              enabled: !_disabledInput(),
              controller: _docNumber,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Document number',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                fillColor: Colors.white,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]+')),
                LengthLimitingTextInputFormatter(14),
              ],
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              autofocus: true,
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Please enter passport number';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              enabled: !_disabledInput(),
              controller: _dob,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Date of Birth',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                fillColor: Colors.white,
              ),
              autofocus: false,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Please select Date of Birth';
                }
                return null;
              },
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final now = DateTime.now();
                final firstDate = DateTime(now.year - 90, now.month, now.day);
                final lastDate = DateTime(now.year - 15, now.month, now.day);
                final initDate = _getDOBDate();
                final date = await _pickDate(context, firstDate, initDate ?? lastDate, lastDate);

                FocusScope.of(context).requestFocus(FocusNode());
                if (date != null) {
                  _dob.text = date;
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              enabled: !_disabledInput(),
              controller: _doe,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Date of Expiry',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                fillColor: Colors.white,
              ),
              autofocus: false,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Please select Date of Expiry';
                }
                return null;
              },
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final now = DateTime.now();
                final firstDate = DateTime(now.year, now.month, now.day + 1);
                final lastDate = DateTime(now.year + 10, now.month + 6, now.day);
                final initDate = _getDOEDate();
                final date = await _pickDate(context, firstDate, initDate ?? firstDate, lastDate);

                FocusScope.of(context).requestFocus(FocusNode());
                if (date != null) {
                  _doe.text = date;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _disabledInput() {
    return _isReading || !_isNfcAvailable;
  }

  void tryDisplayingJpg() {
    try {
      setState(() {
        // Assuming rawImageData has already been set
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image is not in jpg format, trying jpeg2000")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40),
                Text(
                  'MRZ Informations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Lottie.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/scan_mrz_dark.json'
                      : 'assets/scan_mrz_light.json',
                  height: 150,
                ),
                const SizedBox(height: 20),
                _buildMRZForm(context),
                const SizedBox(height: 20),
                if (_isNfcAvailable && _isReading)
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CupertinoActivityIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          radius: 18,
                        ),
                      ),
                    ],
                  ),
                if (_isNfcAvailable && !_isReading)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
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
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          onPressed: () {
                            _initPlatformState();
                            _readMRTD();
                            _showUserInstructions = false;
                          },
                          child: Text('Next', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter your national id card informations and tap next',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                if (!_isNfcAvailable && !_isReading)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
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
                          onPressed: () {
                            _initPlatformState();
                            _showUserInstructions = true;
                          },
                          child: Text('Check NFC', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_showUserInstructions)
                        const SizedBox(height: 20),
                      if (_showUserInstructions)
                        Text(
                          'Enable NFC settings in your mobile and retry',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
