import 'dart:async';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:web3dart/json_rpc.dart';

import '../../../blockchain_back/blockchain/blockachain.dart';
import '../../utils/glassmorphismContainer.dart';

class DeputiesVotingProcessView extends StatefulWidget {
  final bool isConfirming;

  DeputiesVotingProcessView({Key? key, required this.isConfirming}) : super(key: key);

  @override
  _DeputiesVotingProcessViewState createState() => _DeputiesVotingProcessViewState();
}

class _DeputiesVotingProcessViewState extends State<DeputiesVotingProcessView> {
  final _formKey = GlobalKey<FormState>();
  final text_secret = TextEditingController();

  double timeRemainingCircle = 0.0;
  int step = -1;

  Blockchain blockchain = Blockchain();
  List<dynamic> candidates = [];
  List<dynamic> firstNames = [];
  List<dynamic> lastNames = [];
  List<dynamic> imageUrls = [];
  bool _isConfirmButtonDisabled = true;
  bool _isVotingPeriodEnded = false;
  String _castVoteButtonText = 'Cast Vote';

  Timer? _timer;
  Timer? _voterCountTimer;

  Duration _timeRemaining = Duration();
  String timeRemainingText = "00:00:00";

  bool _isTextObscured = true;

  int numberOfVoters = 0; // New state variable for number of voters

  List<dynamic> groups = [];
  List<dynamic> groupNames = [];
  List<dynamic> groupPictures = [];
  List<dynamic> groupAddresses = [];

  int _selectedGroup = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateGroupsAndCandidates());
    _loadDeadline();
    _startTimer();
    _startVoterCountTimer(); // Start the voter count timer
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
        });
      }
    } catch (error) {
      print("Error fetching number of voters: $error"); // Add logging
    }
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
          _castVoteButtonText = 'Cast Vote';
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
          _castVoteButtonText = 'Cast Vote';
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
    if (_selectedGroup == -1) {
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


  Future<void> _openVote() async {
    if (!checkSelection()) return;

    setState(() {
      _isConfirmButtonDisabled = true;
    });

    List<dynamic> args = [
      BigInt.parse(text_secret.text), // Secret as BigInt
      groupAddresses[_selectedGroup] // Group address
    ];
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
          _castVoteButtonText = 'Cast Vote';
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

    List<dynamic> args = [
      blockchain.encodeVoteDeputies(BigInt.parse(text_secret.text), groupAddresses[_selectedGroup]) // Use group address
    ];

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
          desc: "Your vote has been casted!",
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
          _castVoteButtonText = 'Edit Vote';
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


  Future<void> _updateGroupsAndCandidates() async {
    Alert(
      context: context,
      title: "Getting groups and candidates...",
      desc: "Please wait while we fetch the group and candidate details.",
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
        final groupDetails = await blockchain.queryView("getAllDetails", []);
        Navigator.of(context).pop();
        setState(() {
          groupNames = groupDetails[0];
          groupPictures = groupDetails[1];
          groupAddresses = groupDetails[2].map((group) => group[0]).toList(); // Extract group addresses
          groups = List.generate(groupDetails[0].length, (index) {
            return {
              'name': groupNames[index],
              'pictureUrl': groupPictures[index],
              'candidates': groupDetails[2][index]
            };
          });
          candidates = groupDetails[3];
          firstNames = groupDetails[4];
          lastNames = groupDetails[5];
          imageUrls = groupDetails[6];
        });
      } catch (error) {
        Navigator.of(context).pop();
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: error.toString(),
        ).show();
      }
    });
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: ListView(
              children: [
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          textAlign: TextAlign.center,
                          timeRemainingText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Parliamentary groups voting',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        StaggeredGrid.count(
                          crossAxisCount: 1,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          children: List.generate(groups.length, (int groupIndex) {
                            var group = groups[groupIndex];
                            var validCandidates = group['candidates'].where((candidate) => candidates.contains(candidate)).toList();
                            validCandidates.remove(groupAddresses[groupIndex]); // Remove the group address
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGroup = groupIndex;
                                });
                              },
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: (_selectedGroup == groupIndex) ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.background,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.25), // Semi-transparent black overlay
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: glassmorphicContainer(
                                          context: context,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: Container(
                                                  width: 40,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    image: DecorationImage(
                                                      image: NetworkImage(group['pictureUrl']),
                                                      fit: BoxFit.cover,
                                                      onError: (exception, stackTrace) {
                                                        setState(() {
                                                          group['pictureUrl'] = 'assets/placeholder.png';
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  group['name'],
                                                  style: TextStyle(
                                                    color: (_selectedGroup == groupIndex) ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              CarouselSlider(
                                                options: CarouselOptions(
                                                  height: 180,
                                                  enlargeCenterPage: true,
                                                  autoPlay: false,
                                                  aspectRatio: 16 / 9,
                                                  autoPlayCurve: Curves.fastOutSlowIn,
                                                  enableInfiniteScroll: true,
                                                  autoPlayAnimationDuration: Duration(milliseconds: 400),
                                                  viewportFraction: 1,
                                                ),
                                                items: validCandidates.map<Widget>((candidate) {
                                                  int candidateIndex = candidates.indexOf(candidate);
                                                  return Builder(
                                                    builder: (BuildContext context) {
                                                      return Column(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(20),
                                                              image: DecorationImage(
                                                                image: NetworkImage(imageUrls[candidateIndex]),
                                                                fit: BoxFit.cover,
                                                                onError: (exception, stackTrace) {
                                                                  setState(() {
                                                                    imageUrls[candidateIndex] = 'assets/placeholder.png';
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            "${firstNames[candidateIndex]} ${lastNames[candidateIndex]}",
                                                            style: TextStyle(
                                                              color: (_selectedGroup == groupIndex) ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.primary,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Secret code',
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
                            const SizedBox(height: 20),
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
                                    onPressed: _isVotingPeriodEnded
                                        ? null
                                        : () {
                                      _sendVote();
                                    },
                                    child: Text(_castVoteButtonText),
                                  ),
                                ),
                                const SizedBox(width: 10), // Add some space between the buttons
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
                                    onPressed: _isConfirmButtonDisabled || _isVotingPeriodEnded
                                        ? null
                                        : () {
                                      _openVote();
                                    },
                                    child: const Text(
                                      textAlign: TextAlign.center,
                                      'Confirm Vote',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
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

