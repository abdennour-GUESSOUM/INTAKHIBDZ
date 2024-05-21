import 'package:IntakhibDZ/blockchain_back/blockchain/blockchain_authentification.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateGroups());
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
  }

  Future<void> _updateGroups() async {
    print("Fetching groups...");
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

    List<Widget> buildValidContent() {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text(
            "The winning party is",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 140,
          child: Card(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      Align(
                        child: Text("${groups[0].groupName}",
                            style: TextStyle(fontSize: 40,
                                color: Theme.of(context).colorScheme.background, fontWeight: FontWeight.bold)),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: 50,
                          child: Image.network(groups[0].pictureUrl!, fit: BoxFit.fill),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(

                  child: Text("Collected ${groups[0].votes} votes    ${groups[0].percentage!.toStringAsFixed(0)}%", style: TextStyle(color: Theme.of(context).colorScheme.background, fontWeight: FontWeight.bold , fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30),
        Text("Results ranking", style: TextStyle(fontSize: 40)),
        SizedBox(height: 30),
        ...List<Widget>.generate(groups.length, (index) {
          return Card(
            color: Theme.of(context).colorScheme.background.withOpacity(1),
            child: ListTile(
              title: Text("${groups[index].groupName}", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(' Collected ${groups[index].votes} votes          ${groups[index].percentage!.toStringAsFixed(0)}%'),
              trailing: Container(
                width: 40,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: NetworkImage(groups[index].pictureUrl!),
                  ),
                ),
              ),
            ),
          );
        }),
      ];
    }

    List<Widget> content;
    if (valid == null) {
      content = [Center(
    child: Container(
    margin: const EdgeInsets.only(top: 30.0),
    child: Column(
    children: <Widget>[
    Text(
    "Unexpected error",
    style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.primary , fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 20),
    const Text(
    "an error occured during elections!",
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 50),
    Center(
    child: Lottie.asset(
    'assets/invalid_elect.json',
    height: 200,
    ),
    ),
    const SizedBox(height: 50),
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
    )];
    } else if (valid == false) {
      content = [
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
        ),
      ];
    } else if (valid == true) {
      content = buildValidContent();
    } else {
      content = [const Center(
        child: Text(
            "Unknown state",
            style: TextStyle(
                fontSize: 40,
                color: Colors.red
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
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: ListView(
              children: content,
            ),
          ),
        ),
      ),
    );
  }
}
