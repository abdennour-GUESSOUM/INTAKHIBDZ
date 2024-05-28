import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import '../../../blockchain_back/blockchain/blockachain.dart';

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

  List<dynamic> genders = [];
  List<dynamic> jobPositions = [];
  List<dynamic> electoralDistricts = [];
  List<dynamic> politicalAffiliations = [];
  List<dynamic> ages = [];
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

  void _showCandidateInfo(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(0),
          title: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Text(
              '${firstNames[index]} ${lastNames[index]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          content: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrls[index]),
              ),
              Spacer(),
              Spacer(),
              Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(
                        '${genders[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.cake),
                      title: Text(
                        '${ages[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child:ListTile(
                      leading: Icon(Icons.work),
                      title: Text(
                        '${jobPositions[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child:ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(
                        '${electoralDistricts[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.account_balance),
                      title: Text(
                        '${politicalAffiliations[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [],
        );
      },
    );
  }

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
      final result = await blockchain.queryViewSecond("getTotalVotes", []);
      print("Result from getTotalVotes: $result"); // Add logging

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
    final result = await blockchain.queryViewSecond("getVotingDeadline", []);
    if (result.isNotEmpty) {
      final deadline = result[0] as BigInt;
      final currentTime = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final timeRemaining = deadline - currentTime;

      if (!mounted) return; // Added check

      setState(() {
        if (timeRemaining > BigInt.zero) {
          final hours = timeRemaining ~/ BigInt.from(3600);
          final minutes = (timeRemaining % BigInt.from(3600)) ~/ BigInt.from(60);
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


  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final currentTime = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final result = await blockchain.queryViewSecond("getVotingDeadline", []);
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
      AwesomeDialog(
        context: context,
        customHeader: Icon(
          Icons.warning,
          size: 70,
          color: Theme.of(context).colorScheme.primary,
        ),

        dialogType: DialogType.error,
        headerAnimationLoop: false,
        animType: AnimType.topSlide,
        title: "Error",
        desc: (widget.isConfirming)
            ? "Please select the group you voted for"
            : "Please select the group you want to vote for",

        btnOkOnPress: () {},
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
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      title: "Confirming your vote...",
      desc: "",
    ).show();

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        await blockchain.querySecond("confirmVote", args);
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          customHeader: Icon(
            Icons.check_circle,
            size: 50,
            color: Theme.of(context).colorScheme.secondary,
          ),
          dialogType: DialogType.success,
          headerAnimationLoop: false,
          animType: AnimType.topSlide,
          title: "Success",
          desc: "Your vote has been confirmed!",
          btnOkOnPress: (){},
        ).show();

        setState(() {
          _castVoteButtonText = 'Cast Vote';
          _isConfirmButtonDisabled = true;
        });
      } catch (error) {
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          headerAnimationLoop: false,
          animType: AnimType.topSlide,
          title: "Error",
          desc: error.toString(),
          btnOkOnPress: () {},
        ).show();
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

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      title: "Sending your vote...",
      desc: "",
    ).show();

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        await blockchain.querySecond("castVote", args);
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          customHeader: Icon(
            Icons.check_circle,
            size: 50,
            color: Theme.of(context).colorScheme.secondary,
          ),

          dialogType: DialogType.success,
          headerAnimationLoop: false,
          animType: AnimType.topSlide,
          title: "OK",
          desc: "Your vote has been casted!",
          btnOkOnPress: () {},
        ).show();

        setState(() {
          _castVoteButtonText = 'Cast Vote';
          _isConfirmButtonDisabled = false;
        });
      } catch (error) {
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          headerAnimationLoop: false,
          animType: AnimType.topSlide,
          title: "Error",
          desc: error.toString(),
          btnOkOnPress: () {},
        ).show();
      }
    });
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _updateGroupsAndCandidates() async {
    AwesomeDialog(
      context: context,
      customHeader: CircularProgressIndicator(),
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      title: "Getting groups and candidates...",
      desc: "Please wait while we fetch the group and candidate details.",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text("Please wait while we fetch the group and candidate details.",                        textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).show();

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final groupDetails = await blockchain.queryViewSecond("getAllGroupDetails", []);
        final candidateDetails = await blockchain.queryViewSecond("getAllCandidateDetails", []);
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
          candidates = candidateDetails[0];
          firstNames = candidateDetails[1];
          lastNames = candidateDetails[2];
          imageUrls = candidateDetails[3];
          genders = candidateDetails[4];
          jobPositions = candidateDetails[5];
          electoralDistricts = candidateDetails[6];
          politicalAffiliations = candidateDetails[7];
          ages = candidateDetails[8];
        });
      } catch (error) {
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          customHeader: Icon(
            Icons.error,
            size: 50,
            color: Theme.of(context).colorScheme.error,
          ),
          dialogType: DialogType.error,
          headerAnimationLoop: false,
          animType: AnimType.topSlide,
          title: "Error",
          desc: error.toString(),
          btnOkOnPress: () {},
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
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListView(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    height: 60,
                    viewportFraction: 1.0,
                  ),
                  items: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$numberOfVoters already voted !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Parliamentary groups voting',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 300, // Fixed height for horizontal list
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              var group = groups[index];
                              var validCandidates = group['candidates'].where((candidate) => candidates.contains(candidate)).toList();
                              validCandidates.remove(groupAddresses[index]); // Remove the group address
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGroup = index;
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
                                  color: (_selectedGroup == index) ? Theme.of(context).colorScheme.secondary.withOpacity(0.9) : Theme.of(context).colorScheme.background,
                                  child: Container(
                                    width: 300, // Fixed width for cards
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Card(
                                            color: Theme.of(context).colorScheme.background.withOpacity(1),
                                            child: ListTile(
                                              leading: Container(
                                                height: 50,
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: Image.network(group['pictureUrl'])),
                                              ),
                                              title: Text(
                                                group['name'],
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                            child: Text(
                                              "Members list",
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: validCandidates.length,
                                              itemBuilder: (context, candidateIndex) {
                                                int idx = candidates.indexOf(validCandidates[candidateIndex]);
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    side: BorderSide(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  color: Theme.of(context).colorScheme.background.withOpacity(0.9),
                                                  child: ListTile(
                                                    title: Text(
                                                      "${firstNames[idx]} ${lastNames[idx]}",
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    leading: Container(
                                                      height: 50,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(100),
                                                        child: Image.network(imageUrls[idx], fit: BoxFit.fill),
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
                                                      onPressed: () => _showCandidateInfo(idx),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                            label: Text(_castVoteButtonText),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
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
                                            onPressed: _isVotingPeriodEnded ? null : () => _sendVote(),
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
                                            onPressed: _isConfirmButtonDisabled || _isVotingPeriodEnded ? null : () => _openVote(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
