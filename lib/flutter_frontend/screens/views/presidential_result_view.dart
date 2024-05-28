import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
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
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCandidates());
  }

  Future<void> _updateCandidates() async {
    _showLoadingDialog("Getting results...", "");

    Future.delayed(const Duration(milliseconds: 500), () {
      blockchain.queryView("getElectionResults", []).then((value) {
        Navigator.of(context).pop();

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
        });

        _controllerCenter.play(); // Play the confetti controller when candidates are updated
        Future.delayed(const Duration(seconds: 5), () {
          _controllerCenter.stop();
        });
      }).catchError((error) {
        Navigator.of(context).pop();
        String errorMessage = (error is RPCError) ? blockchain.translateError(error) : error.toString();
        if (error.toString().contains("invalid")) {
          errorMessage = "Invalid results!";
          setState(() {
            valid = false;
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
                        ),
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
          Container(
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Congrats ",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Card(
                      color: Theme.of(context).colorScheme.background.withOpacity(1),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: 150,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(candidates[0].imageUrl!, fit: BoxFit.fill)
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${candidates[0].firstName}\n${candidates[0].lastName}",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${candidates[0].votes} votes",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            '${candidates[0].percentage!.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                              backgroundColor: Color(0xFFF1F3F3),
                                              value: candidates[0].percentage! / 100,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Statistics",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  CarouselSlider(

                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 5),
                      height: 350, // Adjust the height to give more space
                      viewportFraction: 1.0,
                    ),
                    items: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1.0,
                          ),
                        ),
                        color: Theme.of(context).colorScheme.background.withOpacity(1),
                        child: Container(
                          height: 350,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),

                              borderData: FlBorderData(show: false),
                              sectionsSpace: 0,
                              centerSpaceRadius: 0,
                              sections: showingSections(),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1.0,
                          ),
                        ),
                        color: Theme.of(context).colorScheme.background.withOpacity(1),
                        child: Container(
                          height: 350,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.symmetric(
                                    horizontal: BorderSide(
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  leftTitles: AxisTitles(
                                    drawBelowEverything: true,
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 1 == 0) {
                                          return Text(
                                            value.toInt().toString(),
                                            textAlign: TextAlign.left,
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image.network(
                                              candidates[index].imageUrl!,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(),
                                  topTitles: const AxisTitles(),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                                ),
                                barGroups: candidates.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  PresidentWinnerModel candidate = entry.value;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: candidate.votes!.toDouble(),
                                        color: getColor(index),
                                        width: 6,
                                      ),
                                    ],
                                    showingTooltipIndicators: touchedIndex == index ? [0] : [],
                                  );
                                }).toList(),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  handleBuiltInTouches: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (
                                        BarChartGroupData group,
                                        int groupIndex,
                                        BarChartRodData rod,
                                        int rodIndex,
                                        ) {
                                      return BarTooltipItem(
                                        rod.toY.toStringAsFixed(0) + ' votes',
                                        TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: rod.color,
                                          fontSize: 18,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black26,
                                              blurRadius: 12,
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  touchCallback: (event, response) {
                                    if (event.isInterestedForInteractions &&
                                        response != null &&
                                        response.spot != null) {
                                      setState(() {
                                        touchedIndex = response.spot!.touchedBarGroupIndex;
                                      });
                                    } else {
                                      setState(() {
                                        touchedIndex = -1;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Candidates results",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  Container(
                    height: 320,
                    child: ListView.builder(
                      itemCount: candidates.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index < candidates.length) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0,
                              ),
                            ),
                            color: Theme.of(context).colorScheme.background.withOpacity(1),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(.0),
                                leading: Container(
                                  height: 60,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(candidates[index].imageUrl!, fit: BoxFit.cover)),
                                ),
                                title: Text(
                                  "${candidates[index].firstName} ${candidates[index].lastName}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                                subtitle: Text(
                                  ' ${candidates[index].votes.toString()} Votes',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        '${candidates[index].percentage!.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Container(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                          backgroundColor: Color(0xFFF1F3F3),
                                          value: candidates[index].percentage! / 100,
                                        ),
                                      ),
                                    ],
                                  ),
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Stack(
              children: [
                ListView(
                  children: <Widget>[
                    body,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return candidates.asMap().entries.map((entry) {
      int index = entry.key;
      PresidentWinnerModel candidate = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 130.0 : 120.0;
      final widgetSize = isTouched ? 75.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: getColor(index),
        value: candidate.percentage,
        title: '${candidate.percentage!.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        titlePositionPercentageOffset: 0.5,
        badgeWidget: _Badge(
          candidate.imageUrl!,
          size: widgetSize,
          borderColor: Theme.of(context).colorScheme.background,
        ),
        badgePositionPercentageOffset: 1,
      );
    }).toList();
  }

  Color getColor(int index) {
    switch (index % 5) {
      case 0:
        return Color(0xFF0C5143); //0xFF3BFF49
      case 1:
        return Color(0xFFFFC300);
      case 2:
        return Color(0xFF6E1BFF);
      case 3:
        return Color(0xFF2196F3);
      case 4:
        return Color(0xFFE80054);
      default:
        return Color(0xFF50E4FF);
    }
  }

  void _showLoadingDialog(String title, String description) {
    AwesomeDialog(
      context: context,
      customHeader: CircularProgressIndicator(),


      dialogType: DialogType.noHeader,
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

class _Badge extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color borderColor;

  const _Badge(
      this.imageUrl, {
        Key? key,
        required this.size,
        required this.borderColor,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: (size / 2),
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: (size / 2) - 3,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
