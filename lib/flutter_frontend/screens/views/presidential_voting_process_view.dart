import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/json_rpc.dart';

import '../../../blockchain_back/blockchain/blockachain.dart';

class PresidentialVotingProcessView extends StatefulWidget {
  final bool isConfirming;

  PresidentialVotingProcessView({Key? key, required this.isConfirming}) : super(key: key);

  @override
  _PresidentialVotingProcessViewState createState() => _PresidentialVotingProcessViewState();
}

class _PresidentialVotingProcessViewState extends State<PresidentialVotingProcessView> {
  final _formKey = GlobalKey<FormState>();
  final text_secret = TextEditingController();

  bool _voteConfirmed = false;
  double timeRemainingCircle = 0.0;
  int step = -1;

  int voters_count = 5;

  double total_vote_percentage = 0.0;

  Blockchain blockchain = Blockchain();
  List<dynamic> candidates = [];
  List<dynamic> firstNames = [];
  List<dynamic> lastNames = [];
  List<dynamic> imageUrls = [];
  int _selected = -1;

  bool _isConfirmButtonDisabled = true;
  bool _isVotingPeriodEnded = false;
  String _submitVoteButtonText = 'Submit Vote';

  Timer? _timer;
  Timer? _voterCountTimer;

  Duration _timeRemaining = Duration();
  String timeRemainingText = "00:00:00";

  bool _isTextObscured = true;

  int numberOfVoters = 0;
  int totalVoters = 10; // New state variable for total voters

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCandidates());
    _loadDeadline();
    _startTimer();
    _startVoterCountTimer(); // Start the voter count timer
    _fetchTotalVoters(); // Fetch the total number of voters
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voterCountTimer?.cancel();
    text_secret.dispose();
    super.dispose();
  }

  Future<void> _fetchNumberOfVoters() async {
    try {
      final result = await blockchain.queryView("get_vote_count", []);
      print("Result from get_vote_count: $result"); // Add logging

      if (result.isNotEmpty) {
        setState(() {
          numberOfVoters = int.tryParse(result[0].toString()) ?? 0;
          _updateVotePercentage(); // Update vote percentage
        });
      }
    } catch (error) {
      print("Error fetching number of voters: $error"); // Add logging
    }
  }

  Future<void> _fetchTotalVoters() async {
    try {
      final result = await blockchain.queryView("get_total_voters", []);
      print("Result from get_total_voters: $result"); // Add logging

      if (result.isNotEmpty) {
        setState(() {
          totalVoters = int.tryParse(result[0].toString()) ?? 100;
          _updateVotePercentage(); // Update vote percentage
        });
      }
    } catch (error) {
      print("Error fetching total voters: $error"); // Add logging
    }
  }

  void _updateVotePercentage() {
    setState(() {
      if (totalVoters > 0) {  // Ensure there are voters to divide by
        double percentage = (numberOfVoters / totalVoters) * 100;
        total_vote_percentage = percentage.clamp(0.0, 100.0);
      } else {
        total_vote_percentage = 0.0;  // Set to 0 if no voters
      }
    });
  }

  void _startVoterCountTimer() {
    _voterCountTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _fetchNumberOfVoters();
    });
  }

  Future<void> _loadDeadline() async {
    final result = await blockchain.queryView("get_deadline", []);
    if (result.isNotEmpty) {
      final deadline = result[0] as BigInt;
      final currentTime = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final timeRemaining = deadline - currentTime;

      if (!mounted) return; // Added check

      setState(() {
        if (timeRemaining > BigInt.zero) {
          final hours = (timeRemaining / BigInt.from(3600)).toInt();
          final minutes = ((timeRemaining % BigInt.from(3600)) / BigInt.from(60)).toInt();
          final seconds = (timeRemaining % BigInt.from(60)).toInt();

          timeRemainingText = "$hours:$minutes:$seconds";
          timeRemainingCircle = timeRemaining.toDouble() / deadline.toDouble();
          _isVotingPeriodEnded = false;
          _isConfirmButtonDisabled = false;
        } else {
          timeRemainingText = "Voting period has ended";
          timeRemainingCircle = 1.0;
          _isVotingPeriodEnded = true;
          _submitVoteButtonText = 'Submit Vote';
          _isConfirmButtonDisabled = true;
        }
      });
    } else {
      if (!mounted) return; // Added check

      setState(() {
        timeRemainingText = "Failed to get status";
        timeRemainingCircle = 0.0;
      });
    }
  }

  Future<void> _updateTimeRemaining() async {
    final result = await blockchain.queryView("get_deadline", []);
    if (result.isNotEmpty) {
      final deadline = result[0] as BigInt;
      final currentTime = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final timeRemaining = deadline - currentTime;

      if (!mounted) return; // Added check

      setState(() {
        if (timeRemaining > BigInt.zero) {
          final hours = (timeRemaining / BigInt.from(3600)).toInt();
          final minutes = ((timeRemaining % BigInt.from(3600)) / BigInt.from(60)).toInt();
          final seconds = (timeRemaining % BigInt.from(60)).toInt();

          timeRemainingText = "$hours:$minutes:$seconds remaining";
          timeRemainingCircle = timeRemaining.toDouble() / (deadline - currentTime).toDouble();
          _isVotingPeriodEnded = false;
          _isConfirmButtonDisabled = false;
        } else {
          timeRemainingText = "Voting period has ended";
          timeRemainingCircle = 1.0;
          _isVotingPeriodEnded = true;
          _submitVoteButtonText = 'Submit Vote';
          _isConfirmButtonDisabled = true;
        }
      });
    } else {
      if (!mounted) return; // Added check

      setState(() {
        timeRemainingText = "Failed to get status";
        timeRemainingCircle = 0.0;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final currentTime = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final result = await blockchain.queryView("get_deadline", []);
      if (result.isNotEmpty) {
        final deadline = result[0] as BigInt;
        final timeRemaining = deadline - currentTime;

        if (!mounted) return; // Added check

        setState(() {
          if (timeRemaining > BigInt.zero) {
            _timeRemaining = Duration(seconds: timeRemaining.toInt());
            timeRemainingText = _formatDuration(_timeRemaining);
            _isConfirmButtonDisabled = false;
            _isVotingPeriodEnded = false;
          } else {
            timeRemainingText = "Voting period has ended";
            _isConfirmButtonDisabled = true;
            _isVotingPeriodEnded = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  bool checkSelection() {
    if (_selected == -1) {
      Alert(
        buttons: [
          DialogButton(
            child: Text(
              "Retry",
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
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: (widget.isConfirming)
            ? "Please select the president you voted"
            : "Please select the president you want to vote",
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
          animationDuration: const Duration(milliseconds: 500),
          alertElevation: 0,
        ),
      ).show();
      return false;
    }
    return true;
  }

  Future<void> _updateCandidates() async {
    Alert(
      context: context,
      title: "Getting candidates...",
      desc: "Please wait while we fetch the candidate details.",
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

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final value = await blockchain.queryView("get_candidate_names", []);
        Navigator.of(context).pop();
        setState(() {
          candidates = value[0];
          firstNames = value[1];
          lastNames = value[2];
          imageUrls = value[3];
        });
      } catch (error) {
        Navigator.of(context).pop();
        if (error is RPCError) {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: blockchain.translateError(error),
          ).show();
        } else {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: error.toString(),
          ).show();
        }
      }
    });
  }

  Future<void> _openVote() async {
    if (!checkSelection()) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voteConfirmed', true);

    setState(() {
      _isConfirmButtonDisabled = true;
      _voteConfirmed = true; // Set vote as confirmed
    });

    List<dynamic> args = [BigInt.parse(text_secret.text), candidates[_selected]];
    Alert(
      context: context,
      title: "Confirming your vote...",
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
        animationDuration: const Duration(milliseconds: 500),
        alertElevation: 0,
        buttonAreaPadding: const EdgeInsets.all(20),
        alertPadding: const EdgeInsets.all(20),
      ),
    ).show();
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        await blockchain.query("confirm_envelope", args);
        Navigator.of(context).pop();
        Alert(
          buttons: [
            DialogButton(
              child: Text(
                "Go back",
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
          context: context,
          type: AlertType.success,
          title: "OK",
          desc: "Your vote has been confirmed!",
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
            animationDuration: const Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: const EdgeInsets.all(20),
            alertPadding: const EdgeInsets.all(20),
          ),
        ).show();

        setState(() {
          _submitVoteButtonText = 'Submit Vote';
          _isConfirmButtonDisabled = true;
        });
      } catch (error) {
        Navigator.of(context).pop();
        if (error is RPCError) {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: blockchain.translateError(error),
          ).show();
        } else {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: error.toString(),
          ).show();
        }
      } finally {
        setState(() {
          _isConfirmButtonDisabled = false;
        });
      }
    });
  }

  Future<void> _sendVote() async {
    if (!checkSelection()) return;

    List<dynamic> args = [blockchain.encodeVote(BigInt.parse(text_secret.text), candidates[_selected])];

    Alert(
      context: context,
      title: "Sending your vote...",
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
        animationDuration: const Duration(milliseconds: 500),
        alertElevation: 0,
        buttonAreaPadding: const EdgeInsets.all(20),
        alertPadding: const EdgeInsets.all(20),
      ),
    ).show();
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        await blockchain.query("cast_envelope", args);
        Navigator.of(context).pop();
        Alert(
          buttons: [
            DialogButton(
              child: Text(
                "Go back",
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
          context: context,
          type: AlertType.success,
          title: "OK",
          desc: "Your vote has been submited!",
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
            animationDuration: const Duration(milliseconds: 500),
            alertElevation: 0,
            buttonAreaPadding: const EdgeInsets.all(20),
            alertPadding: const EdgeInsets.all(20),
          ),
        ).show();

        setState(() {
          _submitVoteButtonText = 'Edit Vote';
          _isConfirmButtonDisabled = false;
        });
      } catch (error) {
        Navigator.of(context).pop();
        if (error is RPCError) {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: blockchain.translateError(error),
          ).show();
        } else {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: error.toString(),
          ).show();
        }
      }
    });
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('VOTE', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              elevation: 0,
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Lottie.asset(
                    'assets/voting_animation.json',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListView(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    height: 100, // Adjust the height to give more space
                    viewportFraction: 1.0,
                  ),
                  items: [
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$numberOfVoters total votes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        timeRemainingText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Card(
                    color: Theme.of(context).colorScheme.background.withOpacity(1),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 8, 0, 8),
                      child: Row(
                        children: [
                          Text(
                            'Select a candidate.\n'
                                'Enter your secret code.\n'
                                'Submit / Edit your vote.\n'
                                'Confirm your selection.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${total_vote_percentage.toStringAsFixed(1)}%',  // Display percentage with one decimal
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                height: 70,
                                width: 70,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                  backgroundColor: Color(0xFFF1F3F3),
                                  value: total_vote_percentage / 100,  // Convert to fraction
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Theme.of(context).colorScheme.background,
                              child: Container(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: candidates.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selected = index;
                                          });
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 1.0,
                                            ),
                                          ),
                                          color: (_selected == index)
                                              ? Theme.of(context).colorScheme.secondary.withOpacity(0.9)
                                              : Theme.of(context).colorScheme.background.withOpacity(1),
                                          child: Padding(
                                            padding: EdgeInsets.all(8), // Add padding to the card
                                            child: Center( // Center the content horizontally and vertically
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: Image.network(imageUrls[index], fit: BoxFit.fill),
                                                    ),
                                                  ),
                                                  SizedBox(width: 30), // Add some space between image and text
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "${firstNames[index]} \n${lastNames[index]}",
                                                        style: TextStyle(
                                                          color: (_selected == index)
                                                              ? Colors.white
                                                              : Theme.of(context).colorScheme.primary,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Enter a secret code',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary), // Change color here
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary), // Change color here
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0), // Change color and width here
                                    ),
                                    contentPadding: EdgeInsets.all(16.0),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isTextObscured ? Icons.visibility : Icons.visibility_off,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isTextObscured = !_isTextObscured;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a secret code';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: text_secret,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  obscureText: _isTextObscured, // Add this line
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly for even spacing
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0), // Add padding around the button for better spacing
                                            child: ElevatedButton.icon(
                                              icon: Icon(Icons.send), // Add an icon for visual clarity
                                              label: Text(_submitVoteButtonText),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                backgroundColor: Theme.of(context).colorScheme.secondary, // Button background color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30.0),
                                                  side: BorderSide(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: 12.0), // Vertical padding for taller buttons
                                              ),
                                              onPressed: (_isVotingPeriodEnded || _voteConfirmed) ? null : () => _sendVote(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly for even spacing
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0), // Add padding around the button for better spacing
                                            child: ElevatedButton.icon(
                                              icon: Icon(Icons.check_circle), // Add an icon for visual clarity
                                              label: Text('Confirm Vote'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                backgroundColor: Theme.of(context).colorScheme.primary, // Button background color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30.0),
                                                  side: BorderSide(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: 12.0), // Vertical padding for taller buttons
                                              ),
                                              onPressed: (_isConfirmButtonDisabled || _isVotingPeriodEnded || _voteConfirmed) ? null : () => _openVote(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
