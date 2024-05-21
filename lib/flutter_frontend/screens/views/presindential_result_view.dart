import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:web3dart/json_rpc.dart';

import '../../../blockchain_back/blockchain/blockachain.dart';
import '../../../blockchain_back/blockchain/blockchain_authentification.dart';
import '../../../blockchain_back/blockchain/utils.dart';
import '../../../blockchain_back/blockchain/president_winner_model.dart';

class PresidentialResultView extends StatefulWidget {
  @override
  _PresidentialResultViewState createState() => _PresidentialResultViewState();
}

class _PresidentialResultViewState extends State<PresidentialResultView> {
  Blockchain blockchain = Blockchain();
  bool? valid;

  late ConfettiController _controllerCenter;
  List<PresidentWinnerModel> candidates = [PresidentWinnerModel("Loading", BigInt.zero, "Loading", "Loading", "Loading", 0.0)];

  @override
  void initState() {
    super.initState();
    print("Initializing state...");
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCandidates());
  }

  Future<void> _updateCandidates() async {
    print("Fetching candidates...");
    Alert(
      context: context,
      title: "Getting results...",
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

    Future.delayed(const Duration(milliseconds: 500), () {
      blockchain.queryView("get_results", []).then((value) {
        Navigator.of(context).pop();
        print("Results fetched successfully: $value");

        setState(() {
          candidates = [];
          BigInt totalVotes = BigInt.zero;

          // Calculate total votes
          for (int i = 0; i < value[1].length; i++) {
            totalVotes += BigInt.parse(value[1][i].toString());
          }

          // Add candidates and calculate percentages
          for (int i = 0; i < value[0].length; i++) {
            if (i < value[1].length && i < value[2].length && i < value[3].length && i < value[4].length) {
              String address = value[0][i].toString();
              BigInt votes = BigInt.parse(value[1][i].toString());
              String firstName = value[2][i].toString();
              String lastName = value[3][i].toString();
              String imageUrl = value[4][i].toString();
              double percentage = (votes / totalVotes * 100).toDouble();

              candidates.add(PresidentWinnerModel(address, votes, firstName, lastName, imageUrl, percentage));
            }
          }
          candidates.sort((a, b) => b.votes!.compareTo(a.votes!));
          valid = true;
          print("Candidates updated and sorted. 'valid' set to true.");
        });

        _controllerCenter.play(); // Play the confetti controller when candidates are updated
        Future.delayed(const Duration(seconds: 5), () {
          _controllerCenter.stop();
        });
      }).catchError((error) {
        Navigator.of(context).pop();
        print('Error fetching results: $error');
        String errorMessage = (error is RPCError) ? blockchain.translateError(error) : error.toString();
        if (error.toString().contains("invalid")) {
          errorMessage = "Election results invalid due to tie!";
          setState(() {
            valid = false;
            print("Election results invalid due to tie. 'valid' set to false.");
          });
        }
        Alert(
          context: context,
          title: "Error",
          desc: "",
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
          content: Container(
            height: 150, // Set your desired height
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/invalid_elect.json',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          buttons: [
            DialogButton(
              child: Text(
                "ok",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              color: Theme.of(context).colorScheme.secondary,
              radius: BorderRadius.circular(10.0),
              width: 120,
            ),
          ],
        ).show();
      });
    });
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI with 'valid' status as: $valid");
    Widget body = const Center(
      child: Text(
        "Unknown state",
        style: TextStyle(fontSize: 40, color: Colors.red),
      ),
    );

    if (valid == null) {
      body = Container();
    } else if (valid == false) {
      body = Center(
        child: Container(
          margin: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: <Widget>[
              Text(
                "Invalid Elections",
                style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.primary , fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "There was a tie, Elections are invalid!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Center(
                child: Lottie.asset(
                  'assets/invalid_elect.json',
                  height: 200,
                ),
              ),
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ), // Border color and width
                      ),
                    ),
                    onPressed: () {
                      blockchain.logout();
                      setState(() {
                        Navigator.pushAndRemoveUntil(
                          context,
                          SlideRightRoute(page: BlockchainAuthentification(documentNumber: '1122334455')),
                              (Route<dynamic> route) => false,
                        );
                      });
                    },
                    child: const Text("Log Out"),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (valid == true) {
      body = Column(
        children: [
          Center(
            child: Container(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _controllerCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: true,
                      numberOfParticles: 30,
                      maxBlastForce: 20,
                      minBlastForce: 10,
                      emissionFrequency: 0.06,
                      gravity: 0.2,
                      particleDrag: 0.05,
                      colors: [
                        Colors.green.withOpacity(0.7),
                        Colors.white.withOpacity(0.7),
                        Colors.red.withOpacity(0.7),
                      ],
                      createParticlePath: (size) {
                        final Path path = Path();
                        double radius = size.width / 5;
                        path.addPolygon([
                          Offset(radius, 0),
                          Offset(1.5 * radius, radius),
                          Offset(1.5 * radius, 2.5 * radius),
                          Offset(0.5 * radius, 2.5 * radius),
                          Offset(0.5 * radius, radius),
                        ], true);
                        return path;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      "The new president is ",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 226,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      image: DecorationImage(
                        image: NetworkImage(candidates[0].imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Theme.of(context).colorScheme.secondary,
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Winner!",
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${candidates[0].firstName}\n${candidates[0].lastName}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.background,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Collected ${candidates[0].votes} votes (${candidates[0].percentage!.toStringAsFixed(2)}%)",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.background,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Results",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: ListView.builder(
                      itemCount: candidates.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index < candidates.length) {
                          return Card(
                            color: Theme.of(context).colorScheme.background.withOpacity(1),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8.0),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(candidates[index].imageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                trailing: ExcludeSemantics(
                                  child: Stack(
                                    children: [
                                      Text(
                                        (() {
                                          switch (index) {
                                            case 0:
                                              return "🥇";
                                            case 1:
                                              return "🥈";
                                            case 2:
                                              return "🥉";
                                          }
                                          return "";
                                        }()),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  "${candidates[index].firstName} ${candidates[index].lastName}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                                subtitle: Text(
                                  '🗳 Votes: ${candidates[index].votes.toString()} (${candidates[index].percentage!.toStringAsFixed(2)}%)',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(); // Return an empty container if the index is out of bounds
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('RESULTS', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Stack(
              children: [
                ListView(
                  children: <Widget>[
                    body
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
