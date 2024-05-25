import 'package:INTAKHIB/blockchain_back/blockchain/blockchain_authentification.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:web3dart/json_rpc.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import '../../../blockchain_back/blockchain/deputies_winner_model.dart';
import '../../../blockchain_back/blockchain/utils.dart';

class DeputiesResultView extends StatefulWidget {
  @override
  _DeputiesResultViewState createState() => _DeputiesResultViewState();
}

class _DeputiesResultViewState extends State<DeputiesResultView> {
  Blockchain blockchain = Blockchain();

  late ConfettiController _controllerCenter;
  List<DeputiesWinnerModel> groups = [DeputiesWinnerModel("Loading", BigInt.zero, "Loading", "", 0.0)];
  bool? valid;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateGroups());
  }

  Future<void> _updateGroups() async {
    print("Fetching groups...");
    _showLoadingDialog("Getting results...", "");

    Future.delayed(const Duration(milliseconds: 500), () {
      blockchain.queryViewSecond("get_results", []).then((value) {
        Navigator.of(context).pop();
        print("Results fetched successfully: $value");
        setState(() {
          groups = [];
          BigInt totalVotes = BigInt.zero;

          // Calculate total votes
          for (int i = 0; i < value[0].length; i++) {
            totalVotes += BigInt.parse(value[1][i].toString());
          }

          // Add groups and calculate percentages
          for (int i = 0; i < value[0].length; i++) {
            String groupAddr = value[0][i].toString();
            BigInt votes = BigInt.parse(value[1][i].toString());
            String groupName = value[2][i].toString();
            String pictureUrl = value[3][i].toString();
            double percentage = (votes / totalVotes * 100).toDouble();

            groups.add(DeputiesWinnerModel(groupAddr, votes, groupName, pictureUrl, percentage));
          }

          // Sort groups by votes in descending order
          groups.sort((a, b) => b.votes!.compareTo(a.votes!));
          valid = true;
          print("Groups updated and sorted. 'valid' set to true.");
        });
        _controllerCenter.play();
        Future.delayed(const Duration(seconds: 5), () {
          _controllerCenter.stop();
        });
      }).catchError((error) {
        Navigator.of(context).pop();
        print('Error fetching results: $error');
        String errorMessage = (error is RPCError) ? blockchain.translateError(error) : error.toString();
        if (error.toString().contains("invalid")) {
          errorMessage = "Invalid results!";
          setState(() {
            valid = false;
            print("Election results invalid due to tie. 'valid' set to false.");
          });
        }
        _showErrorDialog(errorMessage);
      });
    });
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI with 'valid' status as: $valid");

    List<Widget> buildValidContent() {
      return [
        Stack(
          children: [
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "The majority winning group",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  color: Theme.of(context).colorScheme.background.withOpacity(1),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 50,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(groups[0].pictureUrl!, fit: BoxFit.fill)),
                        ),
                      ),
                      Expanded(  // Use Expanded here
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,  // Ensure alignment at the start of the column
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("${groups[0].groupName}",
                                    style: TextStyle(fontSize: 20,
                                        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("${groups[0].votes} votes with a ${groups[0].percentage!.toStringAsFixed(0)}%", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold , fontSize: 20)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,

                  child: Text("Results ranking",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ...List<Widget>.generate(groups.length, (index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1.0,
                      ),
                    ),

                    color: Theme.of(context).colorScheme.background.withOpacity(1),
                    child: Container(
                      child: ListTile(
                        title: Text("${groups[index].groupName}", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        subtitle: Text(' total ${groups[index].votes} votes          ${groups[index].percentage!.toStringAsFixed(0)}%'),
                        trailing:  Container(
                          height: 60,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),

                              child: Image.network(groups[index].pictureUrl!, fit: BoxFit.fill)),
                        ),

                      ),
                    ),
                  );
                }),
              ],
            ),

          ],
        ),

      ];
    }

    List<Widget> content;
    if (valid == false) {
      content = [
        Stack(
          children: [
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

            Center(
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
                      "Elections are invalid!",
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
            ),
          ],
        ),
      ];
    } else if (valid == true) {
      content = buildValidContent();
    } else {
      content = [ Center(
        child: Text(
            "Unknown state",
            style: TextStyle(
              fontSize: 40,
              color: Theme.of(context).colorScheme.background,
            )
        ),
      )];
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
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: ListView(
              children: content,
            ),
          ),
        ),
      ),
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
