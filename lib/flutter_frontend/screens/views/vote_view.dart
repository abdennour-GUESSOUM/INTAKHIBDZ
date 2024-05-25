import 'package:INTAKHIB/flutter_frontend/screens/views/deputies_result_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/presidential_voting_process_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/presidential_result_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import '../../utils/glassmorphismContainer.dart';
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

  Widget _buildHorizontalList(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => _buildGlassmorphicContainer(
          context: context,
          height: 155,
          width: 260,
          image: 'assets/images/news_${index + 1}.jpg', // Placeholder for image assets
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({
    required BuildContext context,
    required double width,
    required double height,
    String? additionalText,
    String? image,
    Widget? child,
  }) {
    return glassmorphicContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (child != null) // Render the child widget if provided
            child,
          if (image != null) // Render the image if provided
            Container(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height * 0.89,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 50); // Placeholder for error cases
                },
              ),
            ),
          if (additionalText != null) // Render additional text if provided
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                additionalText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      height: height,
      width: width,
    );
  }
}
