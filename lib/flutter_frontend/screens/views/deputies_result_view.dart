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
  int touchedIndex = -1;

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
      blockchain.queryViewSecond("getElectionResults", []).then((value) {
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
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      // Show only integer values
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
                                            groups[index].pictureUrl!,
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
                              barGroups: groups.asMap().entries.map((entry) {
                                int index = entry.key;
                                DeputiesWinnerModel candidate = entry.value;
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
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Results ranking",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
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
                        trailing: Container(
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(groups[index].pictureUrl!, fit: BoxFit.fill),
                          ),
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
      content = [
        Center(
          child: Text(
            "Unknown state",
            style: TextStyle(
              fontSize: 40,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ];
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

  List<PieChartSectionData> showingSections() {
    return groups.asMap().entries.map((entry) {
      int index = entry.key;
      DeputiesWinnerModel candidate = entry.value;
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
          candidate.pictureUrl!,
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
        return Color(0xFF0C5143);
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

class LineChartSample5 extends StatefulWidget {
  const LineChartSample5({
    super.key,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? Colors.blue,
        gradientColor2 = gradientColor2 ?? Colors.green,
        gradientColor3 = gradientColor3 ?? Colors.red,
        indicatorStrokeColor = indicatorStrokeColor ?? Colors.black;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  @override
  State<LineChartSample5> createState() => _LineChartSample5State();
}

class _LineChartSample5State extends State<LineChartSample5> {
  List<int> showingTooltipOnSpots = [1, 3, 5];

  List<FlSpot> get allSpots => const [
    FlSpot(0, 1),
    FlSpot(1, 2),
    FlSpot(2, 1.5),
    FlSpot(3, 3),
    FlSpot(4, 3.5),
    FlSpot(5, 5),
    FlSpot(6, 8),
  ];

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.pink,
      fontFamily: 'Digital',
      fontSize: 18 * chartWidth / 500,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '00:00';
        break;
      case 1:
        text = '04:00';
        break;
      case 2:
        text = '08:00';
        break;
      case 3:
        text = '12:00';
        break;
      case 4:
        text = '16:00';
        break;
      case 5:
        text = '20:00';
        break;
      case 6:
        text = '23:59';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: true,
        barWidth: 4,
        shadow: const Shadow(
          blurRadius: 8,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              widget.gradientColor1.withOpacity(0.4),
              widget.gradientColor2.withOpacity(0.4),
              widget.gradientColor3.withOpacity(0.4),
            ],
          ),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(
          colors: [
            widget.gradientColor1,
            widget.gradientColor2,
            widget.gradientColor3,
          ],
          stops: const [0.1, 0.4, 0.9],
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return AspectRatio(
      aspectRatio: 2.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 10,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return LineChart(
            LineChartData(
              showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    tooltipsOnBar,
                    lineBarsData.indexOf(tooltipsOnBar),
                    tooltipsOnBar.spots[index],
                  ),
                ]);
              }).toList(),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return;
                  }
                  if (event is FlTapUpEvent) {
                    final spotIndex = response.lineBarSpots!.first.spotIndex;
                    setState(() {
                      if (showingTooltipOnSpots.contains(spotIndex)) {
                        showingTooltipOnSpots.remove(spotIndex);
                      } else {
                        showingTooltipOnSpots.add(spotIndex);
                      }
                    });
                  }
                },
                mouseCursorResolver:
                    (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return SystemMouseCursors.basic;
                  }
                  return SystemMouseCursors.click;
                },
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(
                        color: Colors.pink,
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 8,
                              color: lerpGradient(
                                barData.gradient!.colors,
                                barData.gradient!.stops!,
                                percent / 100,
                              ),
                              strokeWidth: 2,
                              strokeColor: widget.indicatorStrokeColor,
                            ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.pink,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        lineBarSpot.y.toString(),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lineBarsData,
              minY: 0,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  axisNameWidget: Text('count'),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: false,
                    interval: 1,
                    reservedSize: 0,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return bottomTitleWidgets(
                        value,
                        meta,
                        constraints.maxWidth,
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(
                  axisNameWidget: Text('count'),
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 0,
                  ),
                ),
                topTitles: const AxisTitles(
                  axisNameWidget: Text(
                    'Wall clock',
                    textAlign: TextAlign.left,
                  ),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 0,
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Lerps between a [LinearGradient] colors, based on [t]
Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (colors.length == 1) {
    return colors[0];
  }

  if (stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / (colors.length - 1);
      stops.add(percent * index);
    });
  }





  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];
    final leftColor = colors[s];
    final rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}
