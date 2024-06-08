import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../dmrtd_lib/src/lds/df1/efdg2.dart';
import '../dmrtd_lib/src/crypto/aa_pubkey.dart';
import '../dmrtd_lib/src/lds/df1/dg.dart';
import '../dmrtd_lib/src/lds/df1/efcom.dart';
import '../dmrtd_lib/extensions.dart';
import '../dmrtd_lib/src/lds/df1/efdg1.dart';
import '../dmrtd_lib/src/lds/df1/efdg10.dart';
import '../dmrtd_lib/src/lds/df1/efdg11.dart';
import '../dmrtd_lib/src/lds/df1/efdg12.dart';
import '../dmrtd_lib/src/lds/df1/efdg13.dart';
import '../dmrtd_lib/src/lds/df1/efdg14.dart';
import '../dmrtd_lib/src/lds/df1/efdg15.dart';
import '../dmrtd_lib/src/lds/df1/efdg16.dart';
import '../dmrtd_lib/src/lds/df1/efdg3.dart';
import '../dmrtd_lib/src/lds/df1/efdg4.dart';
import '../dmrtd_lib/src/lds/df1/efdg5.dart';
import '../dmrtd_lib/src/lds/df1/efdg6.dart';
import '../dmrtd_lib/src/lds/df1/efdg7.dart';
import '../dmrtd_lib/src/lds/df1/efdg8.dart';
import '../dmrtd_lib/src/lds/df1/efdg9.dart';
import '../dmrtd_lib/src/lds/df1/efsod.dart';
import '../dmrtd_lib/src/lds/efcard_access.dart';
import '../dmrtd_lib/src/lds/efcard_security.dart';
import '../dmrtd_lib/src/lds/mrz.dart';
import '../dmrtd_lib/src/lds/tlv.dart';

class MrtdData {
  EfCardAccess? cardAccess;
  EfCardSecurity? cardSecurity;
  EfCOM? com;
  EfSOD? sod;
  EfDG1? dg1;
  EfDG2? dg2;
  EfDG3? dg3;
  EfDG4? dg4;
  EfDG5? dg5;
  EfDG6? dg6;
  EfDG7? dg7;
  EfDG8? dg8;
  EfDG9? dg9;
  EfDG10? dg10;
  EfDG11? dg11;
  EfDG12? dg12;
  EfDG13? dg13;
  EfDG14? dg14;
  EfDG15? dg15;
  EfDG16? dg16;
  Uint8List? aaSig;

}

class MrtdDataStorage {
  final String documentNumber;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String nationality;
  final String dateOfExpiry;
  final Uint8List imageData;
  final Uint8List rawHandSignatureData;

  MrtdDataStorage({
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.nationality,
    required this.dateOfExpiry,
    required this.imageData,
    required this.rawHandSignatureData,
  });

  factory MrtdDataStorage.fromStorage(Map<String, dynamic> map) {
    return MrtdDataStorage(
      documentNumber: map['documentNumber'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      dateOfBirth: map['dateOfBirth'],
      nationality: map['nationality'],
      dateOfExpiry: map['dateOfExpiry'],
      imageData: map['imageData'],
      rawHandSignatureData: map['signatureData'],
    );
  }
}


final Map<DgTag, String> dgTagToString = {
  EfDG1.TAG: 'EF.DG1',
  EfDG2.TAG: 'EF.DG2',
  EfDG3.TAG: 'EF.DG3',
  EfDG4.TAG: 'EF.DG4',
  EfDG5.TAG: 'EF.DG5',
  EfDG6.TAG: 'EF.DG6',
  EfDG7.TAG: 'EF.DG7',
  EfDG8.TAG: 'EF.DG8',
  EfDG9.TAG: 'EF.DG9',
  EfDG10.TAG: 'EF.DG10',
  EfDG11.TAG: 'EF.DG11',
  EfDG12.TAG: 'EF.DG12',
  EfDG13.TAG: 'EF.DG13',
  EfDG14.TAG: 'EF.DG14',
  EfDG15.TAG: 'EF.DG15',
  EfDG16.TAG: 'EF.DG16'
};
String formatEfCom(final EfCOM efCom) {
  var str = "version: ${efCom.version}\n"
      "unicode version: ${efCom.unicodeVersion}\n"
      "DG tags:";

  for (final t in efCom.dgTags) {
    try {
      str += " ${dgTagToString[t]!}";
    } catch (e) {
      str += " 0x${t.value.toRadixString(16)}";
    }
  }
  return str;
}
String formatMRZ(final MRZ mrz) {
  return "MRZ\n"
      "Version: ${mrz.version}\n" +
      "Document Type: ${mrz.documentCode}\n" +
      "Document Number: ${mrz.documentNumber}\n" +
      "Country: ${mrz.country}\n" +
      "Nationality: ${mrz.nationality}\n" +
      "Name: ${mrz.firstName}\n" +
      "Surname: ${mrz.lastName}\n" +
      "Gender: ${mrz.gender}\n" +
      "Date of Birth: ${DateFormat.yMd().format(mrz.dateOfBirth)}\n" +
      "Date of Expiry: ${DateFormat.yMd().format(mrz.dateOfExpiry)}\n" ;
}

String formatDG11(final EfDG11 dg11) {
  return
    //"Full Name: ${dg11.nameOfHolder}\n" +
    "-NIN: ${dg11.personalNumber}" ;
       // "-Full Date of Birth: ${dg11.fullDateOfBirth != null ? DateFormat.yMd().format(dg11.fullDateOfBirth!) : 'N/A'}\n" +
        // "Place of Birth: ${dg11.placeOfBirth}\n" +
        // "Permanent Address: ${dg11.permanentAddress}\n" +
        // "Telephone: ${dg11.telephone}\n" +
        // "Profession: ${dg11.profession}\n" +
        // "Title: ${dg11.title}\n" +
        //"Personal Summary: ${dg11.personalSummary}\n" +
        //"-Proof of Citizenship: ${dg11.proofOfCitizenship != null ? 'Available' : 'Not Available'}\n" ;
  // "Other Valid TD Numbers: ${dg11.otherValidTDNumbers}\n" +
  //"Blood Type: ${dg11.custodyInformation}";
}
String formatDG2(final EfDG2 dg2) {
  return "DG2\n"
      "faceImageType ${dg2.faceImageType}\n" +
      "facialRecordDataLength ${dg2.facialRecordDataLength}\n" +
      "imageHeight ${dg2.imageHeight}\n" +
      "imageType: ${dg2.imageType}\n" +
      "lengthOfRecord ${dg2.lengthOfRecord}\n" +
      "numberOfFacialImages ${dg2.numberOfFacialImages}\n" +
      "poseAngle ${dg2.poseAngle}";
}
String convertToReadableFormat(String input) {
  if (input.isEmpty) {
    return input;
  }

  String readableText = input.replaceAll('_', ' ');

  return readableText;
}
String formatDG15(final EfDG15 dg15) {
  var str = "EF.DG15:\n"
      "AAPublicKey\n"
      "type: ";

  final rawSubPubKey = dg15.aaPublicKey.rawSubjectPublicKey();
  if (dg15.aaPublicKey.type == AAPublicKeyType.RSA) {
    final tvSubPubKey = TLV.fromBytes(rawSubPubKey);
    var rawSeq = tvSubPubKey.value;
    if (rawSeq[0] == 0x00) {
      rawSeq = rawSeq.sublist(1);
    }

    final tvKeySeq = TLV.fromBytes(rawSeq);
    final tvModule = TLV.decode(tvKeySeq.value);
    final tvExp = TLV.decode(tvKeySeq.value.sublist(tvModule.encodedLen));

    str += "RSA\n"
        "exponent: ${tvExp.value.hex()}\n"
        "modulus: ${tvModule.value.hex()}";
  } else {
    str += "EC\n    SubjectPublicKey: ${rawSubPubKey.hex()}";
  }
  return str;
}
String formatProgressMsg(String message, int percentProgress) {
  final p = (percentProgress / 20).round();
  final full = "🟢 " * p;
  final empty = "⚪️ " * (5 - p);
  return message + "\n\n" + full + empty;
}







