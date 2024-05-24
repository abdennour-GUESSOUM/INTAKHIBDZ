import 'package:IntakhibDZ/flutter_frontend/screens/views/deputies_result_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/presidential_voting_process_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/presidential_result_view.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import 'deputies_voting_process_view.dart';
import 'main_view.dart';

class ResultsView extends StatefulWidget {
  @override
  _ResultsViewState createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  Blockchain blockchain = Blockchain();
  AlertStyle animation = AlertStyle(animationType: AnimationType.grow);
  String quorum_text = "Loading Quorum...";
  double quorum_circle = 0.0;
  int step = -1;
  late bool isPresident;

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _ValidCandidateCheck() async {
    Alert(
      context: context,
      title: "Checking the winner...",
      desc: "Please wait while we fetch the vote results.",
      buttons: [],
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 1,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        descStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        animationDuration: Duration(milliseconds: 500),
        alertElevation: 0,
        buttonAreaPadding: EdgeInsets.all(20),
        alertPadding: EdgeInsets.all(20),
      ),
    ).show();

    try {
      // Get the current deadline
      print("Fetching deadline...");
      final deadlineResult = await blockchain.queryView("get_deadline", []);
      print("Deadline result: $deadlineResult");

      if (deadlineResult.isEmpty) {
        throw Exception("No deadline found.");
      }

      final deadline = BigInt.parse(deadlineResult[0].toString());
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      print("Current time: $currentTime, Deadline: ${deadline.toInt()}");

      if (currentTime > deadline.toInt()) {
        // Call the valid_candidate_check function in the contract if the deadline has passed
        print("Deadline has passed. Calling valid_candidate_check...");
        await blockchain.query("auto_declare_results", []);
        print("auto_declare_results called successfully.");
      } else {
        throw Exception("Voting period has not ended yet.");
      }

      Navigator.of(context).pop();

      // Navigate to the ResultsView
      print("Navigating to Results...");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PresidentialResultView()),
      );
    } catch (error) {
      Navigator.of(context).pop();

      if (error.toString().contains("has already been")) {
        // Navigate to the MainView if the error indicates that the results have already been checked
        print("Results have already been checked. Navigating to home...");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainView()),
        );
        return;
      }

      print("Error during valid_candidate_check: $error");

      // Handle specific RPCError type
      if (error is RPCError) {
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: blockchain.translateError(error),
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            titleStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            descStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            animationDuration: Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: EdgeInsets.all(20),
            alertPadding: EdgeInsets.all(20),
          ),
        ).show();
      } else if (error.toString().contains("Voting period has not ended yet")) {
        // Handle specific error for voting period not ended
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: "Voting period has not ended yet.",
          buttons: [
            DialogButton(
              child: Text(
                "Retry",
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
              color: Theme.of(context).colorScheme.secondary,
              radius: BorderRadius.circular(10.0),
              width: 120,
            ),
          ],
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            titleStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            descStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            animationDuration: Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: EdgeInsets.all(20),
            alertPadding: EdgeInsets.all(20),
          ),
        ).show();
      } else {
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: error.toString(),
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            titleStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            descStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            animationDuration: Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: EdgeInsets.all(20),
            alertPadding: EdgeInsets.all(20),
          ),
        ).show();
      }
    }
  }

  Future<void> _ValidGroupCheck() async {
    Alert(
      context: context,
      title: "Checking the winner...",
      desc: "Please wait while we fetch the vote results.",
      buttons: [],
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 1,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        descStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        animationDuration: Duration(milliseconds: 500),
        alertElevation: 0,
        buttonAreaPadding: EdgeInsets.all(20),
        alertPadding: EdgeInsets.all(20),
      ),
    ).show();

    try {
      // Get the current deadline
      print("Fetching deadline...");
      final deadlineResult = await blockchain.queryViewSecond("get_deadline", []);
      print("Deadline result: $deadlineResult");

      if (deadlineResult.isEmpty) {
        throw Exception("No deadline found.");
      }

      final deadline = BigInt.parse(deadlineResult[0].toString());
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      print("Current time: $currentTime, Deadline: ${deadline.toInt()}");

      if (currentTime > deadline.toInt()) {
        // Call the valid_candidate_check function in the contract if the deadline has passed
        print("Deadline has passed. Calling valid_candidate_check...");
        await blockchain.querySecond("auto_declare_results", []);
        print("auto_declare_results called successfully.");
      } else {
        throw Exception("Voting period has not ended yet.");
      }

      Navigator.of(context).pop();

      // Navigate to the ResultsView
      print("Navigating to Results...");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeputiesResultView()),
      );
    } catch (error) {
      Navigator.of(context).pop();

      if (error.toString().contains("has already been")) {
        // Navigate to the MainView if the error indicates that the results have already been checked
        print("Results have already been checked. Navigating to MainView...");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainView()),
        );
        return;
      }

      print("Error during valid_candidate_check: $error");

      // Handle specific RPCError type
      if (error is RPCError) {
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: blockchain.translateError(error),
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            titleStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            descStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            animationDuration: Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: EdgeInsets.all(20),
            alertPadding: EdgeInsets.all(20),
          ),
        ).show();
      } else if (error.toString().contains("Voting period has not ended yet")) {
        // Handle specific error for voting period not ended
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: "Voting period has not ended yet.",
          buttons: [
            DialogButton(
              child: Text(
                "Retry",
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
              color: Theme.of(context).colorScheme.secondary,
              radius: BorderRadius.circular(10.0),
              width: 120,
            ),
          ],
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            titleStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            descStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            animationDuration: Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: EdgeInsets.all(20),
            alertPadding: EdgeInsets.all(20),
          ),
        ).show();
      } else {
        // Handle generic error
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: error.toString(),
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            titleStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            descStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            animationDuration: Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: EdgeInsets.all(20),
            alertPadding: EdgeInsets.all(20),
          ),
        ).show();
      }
    }
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
                      'Results are here',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Elections result',
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
              SizedBox(height: 20),
              _buildElectionResultCarousel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElectionTypeCarousel(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(height: 300.0),
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

  Widget _buildElectionResultCarousel(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(height: 150.0),
      items: [
        {
          'image': 'assets/images/news_5.jpg',
          'text': 'Presidential Results',
          'onTap': _ValidCandidateCheck,
        },
        {
          'image': 'assets/images/news_3.jpg',
          'text': 'Deputies Results',
          'onTap': _ValidGroupCheck,
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
