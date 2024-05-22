import 'package:IntakhibDZ/flutter_frontend/screens/views/presidential_voting_process_view.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';
import 'presidential_result_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainView createState() => _MainView();
}

class _MainView extends State<MainView> {

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
      title:"Checking the winner...",
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
            color:Theme.of(context).colorScheme.secondary,
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
    Future.delayed(Duration(milliseconds:500), () async =>
    {
      blockchain.query("valid_candidate_check", []).then((value) =>
      {
        Navigator.of(context).pop(),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PresidentialResultView()),
        )
      }).catchError((error) {
        Navigator.of(context).pop();
        if (error.toString().contains("has already been")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainView()),
          );
          return null;
        }
        Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: blockchain.translateError(error),
            style: animation
        ).show();
      })
    });
  }


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateQuorum());
  }

  Future<void> _updateQuorum() async {
    Alert(
      context: context,
      title:"Getting election status...",
      buttons: [],
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        overlayColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color:Theme.of(context).colorScheme.secondary,
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
    Future.delayed(Duration(milliseconds:500), () async => {
      blockchain.queryView("get_status", [await blockchain.myAddr()]).then((value) => {
        Navigator.of(context).pop(),
        if (value[3] == false){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PresidentialResultView()),
          )
        },
        setState(() {
          quorum_text = (value[0] != value[1])
              ? (value[0]-value[1]).toString() + " votes to quorum (" + value[1].toString() + "/" + value[0].toString() + ")"
              : "Elections done! "  +value[0].toString()+"";
          quorum_circle = (value[1]/value[0]);
          print(value);
          if (value[4]){ //addr is a candidate
            step = 3;
            if (!value[3]) { //elections closed
              step = 4;
            }
          } else if (!value[3]){ //elections open
            step = 2;
          } else if (value[1] == value[0]) { //quorum reached
            if (value[2]) { //envelope not open
              step = 1;
            } else { //envelope opened
              step = 2;
            }
          } else { //start
            step = 0;
          }
        })
      }).catchError((error){
        Navigator.of(context).pop();
        Alert(
            context: context,
            type: AlertType.error,
            title:"Error",
            desc: blockchain.translateError(error),
            style: animation
        ).show();
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16 , 0,16,0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('BLOCKCHAIN', style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary)),
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
            padding: const EdgeInsets.all(30.0),
            child: ListView(
              children: <Widget>[
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                          value: quorum_circle,
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(context).colorScheme.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0,
                              ), // Border color and width
                            ),
                          ),
                          onPressed: _updateQuorum,
                          child: Text("Update"),


                        ),
                        title: Text('$quorum_text'),
                      ),
                    ],
                  ),
                ),
                SizedBox( height : 60),

                Row(
                  children: <Widget>[
                    Expanded(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PresidentialVotingProcessView(isConfirming: false)),
                          );
                        },
                        child: const Text('Vote'),
                      ),
                    ),
                    const SizedBox(width: 20), // Add some space between the buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _ValidCandidateCheck ,
                        child: const Text('View Results'),
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

                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
