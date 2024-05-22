import 'package:IntakhibDZ/flutter_frontend/screens/views/deputies_result_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/presidential_voting_process_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/presidential_result_view.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:web3dart/json_rpc.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import '../../utils/glassmorphismContainer.dart';
import 'deputies_voting_process_view.dart';
import 'main_view.dart';


class Voteview extends StatefulWidget {
  @override
  _VoteviewState createState() => _VoteviewState();
}
class _VoteviewState extends State<Voteview> {

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
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18 ,             fontWeight: FontWeight.bold,
                ),
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
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18 ,             fontWeight: FontWeight.bold,
                ),
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
                      'Let\'s begin ',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              _buildHorizontalList(context),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Elections type',
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust as needed
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          height: 300,
                          width: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/news_2.jpg"), // Specify your image path here
                              fit: BoxFit.cover, // This will cover the entire container space
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25), // Semi-transparent black overlay
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PresidentialVotingProcessView(isConfirming: false),
                                  ),
                                );
                              },
                              child: glassmorphicContainer(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: const Text(
                                      'Presidential',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Ensuring text is white for better visibility
                                    ),
                                  ),
                                ),
                                height: 300,
                                width: 250,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          height: 300,
                          width: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/news_5.jpg"), // Specify your image path here
                              fit: BoxFit.cover, // This will cover the entire container space
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25), // Semi-transparent black overlay
                            ),
                            child: GestureDetector(
                              onTap: _ValidCandidateCheck,
                              child: glassmorphicContainer(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: const Text(
                                      'Presidential Results',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Ensuring text is white for better visibility
                                    ),
                                  ),
                                ),
                                height: 300,
                                width: 250,
                              ),
                            ),
                          ),

                        ),
                      ),
                    ),


                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust as needed
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          height: 300,
                          width: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/news_1.jpg"), // Specify your image path here
                              fit: BoxFit.cover, // This will cover the entire container space
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25), // Semi-transparent black overlay
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeputiesVotingProcessView(isConfirming: false),
                                  ),
                                );
                              },
                              child: glassmorphicContainer(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: const Text(
                                      'Deputies',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Ensuring text is white for better visibility
                                    ),
                                  ),
                                ),
                                height: 300,
                                width: 250,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          height: 300,
                          width: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/news_3.jpg"), // Specify your image path here
                              fit: BoxFit.cover, // This will cover the entire container space
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25), // Semi-transparent black overlay
                            ),
                            child: GestureDetector(
                              onTap: _ValidGroupCheck,
                              child: glassmorphicContainer(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: const Text(
                                      'Deputies \nResults',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Ensuring text is white for better visibility
                                    ),
                                  ),
                                ),
                                height: 300,
                                width: 250,
                              ),
                            ),
                          ),

                        ),
                      ),
                    ),



                  ],
                ),
              ),




            ],
          ),
        ),
      ),
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
          image: 'assets/images/news_${index + 1}.jpg',  // Placeholder for image assets
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
  }}




