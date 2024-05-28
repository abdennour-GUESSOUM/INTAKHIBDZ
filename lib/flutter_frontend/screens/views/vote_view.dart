import 'package:INTAKHIB/flutter_frontend/screens/views/presidential_voting_process_view.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import 'deputies_voting_process_view.dart';

class Voteview extends StatefulWidget {
  @override
  _VoteviewState createState() => _VoteviewState();
}

class _VoteviewState extends State<Voteview> {
  Blockchain blockchain = Blockchain();
  int step = -1;

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: Theme.of(context).colorScheme.background,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          animSpeedFactor: 2,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
                    child: Text(
                      'Let\'s get started ',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose elections type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              _buildElectionTypeCarousel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElectionTypeCarousel(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(height: 150.0),
      items: [
        {
          'image': 'assets/images/news_2.jpg',
          'text': 'Presidential',
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PresidentialVotingProcessView(isConfirming: false)),
            );
          }
        },
        {
          'image': 'assets/images/news_1.jpg',
          'text': 'Deputies',
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeputiesVotingProcessView(isConfirming: false)),
            );
          }
        },
      ].map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: item['onTap'] as void Function()?,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Stack(
                    children: [
                      Image.asset(
                        item['image'] as String,
                        fit: BoxFit.cover,
                        height: 300.0,
                        width: double.infinity,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25), // Semi-transparent black overlay
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
                            child: Text(
                              item['text'] as String,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
