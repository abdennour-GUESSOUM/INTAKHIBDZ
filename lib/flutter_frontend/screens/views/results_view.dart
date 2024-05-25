import 'package:INTAKHIB/flutter_frontend/screens/views/deputies_result_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/presidential_voting_process_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/presidential_result_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import 'deputies_voting_process_view.dart';

class ResultsView extends StatefulWidget {
  @override
  _ResultsViewState createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  Blockchain blockchain = Blockchain();
  String quorum_text = "Loading Quorum...";
  double quorum_circle = 0.0;
  int step = -1;
  late bool isPresident;

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _ValidCandidateCheck() async {
    _showLoadingDialog("Checking the winner...", "Please wait while we fetch the vote results.");

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
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
        return;
      }

      print("Error during valid_candidate_check: $error");

      // Handle specific RPCError type
      if (error is RPCError) {
        _showErrorDialog(blockchain.translateError(error));
      } else if (error.toString().contains("Voting period has not ended yet")) {
        // Handle specific error for voting period not ended
        _showErrorDialog("Voting period has not ended yet.");
      } else {
        _showErrorDialog(error.toString());
      }
    }
  }

  Future<void> _ValidGroupCheck() async {
    _showLoadingDialog("Checking the winner...", "Please wait while we fetch the vote results.");

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
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
        return;
      }

      print("Error during valid_candidate_check: $error");

      // Handle specific RPCError type
      if (error is RPCError) {
        _showErrorDialog(blockchain.translateError(error));
      } else if (error.toString().contains("Voting period has not ended yet")) {
        // Handle specific error for voting period not ended
        _showErrorDialog("Voting period has not ended yet.");
      } else {
        _showErrorDialog(error.toString());
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

  void _showLoadingDialog(String title, String description) {
    AwesomeDialog(
      context: context,
      customHeader: CircularProgressIndicator(),
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: title,
      desc: description,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      showCloseIcon: false,
    ).show();
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      customHeader: Icon(
        Icons.error,
        size: 50,
        color: Theme.of(context).colorScheme.error,
      ),

      dialogType: DialogType.error,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: "Error",
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: Theme.of(context).colorScheme.secondary,
    ).show();
  }
}
