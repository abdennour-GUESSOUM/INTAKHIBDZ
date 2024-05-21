import 'package:flutter/material.dart';

class IDCardFrontWidget extends StatelessWidget {
  final String uniqueCardNumber = '407640657';
  final String issuingAuthority = 'بلدية عنابة-عنابة';
  final String releaseDate = '2023.11.07';
  final String expiryDate = '2033.11.06';
  final String nationalIdNumber = '109980841064190002';
  final String lastName = 'عبدالنور';
  final String firstName = 'قسوم';
  final String dateOfBirth = '1998.10.12';
  final String placeOfBirth = 'عنابة';
  final String sex = 'ذكر';
  final String bloodType = 'A+';

  IDCardFrontWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 583.2, // CR80 card size in points
      height: 367.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/front.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            Positioned(left: 180, top: 80, child: Text(uniqueCardNumber, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 90, top: 96, child: Text(issuingAuthority, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(right: 90, top: 124, child: Text(releaseDate, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 90, top: 148, child: Text(expiryDate, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 124, top: 210, child: Text(nationalIdNumber, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 50, top: 263, child: Text(lastName, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(right: 50, top: 228, child: Text(firstName, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(right: 80, top: 308, child: Text(dateOfBirth, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 80, top: 328, child: Text(placeOfBirth, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(left: 305, top: 304, child: Text(sex, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(left: 230, top: 310, child: Text(bloodType, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
