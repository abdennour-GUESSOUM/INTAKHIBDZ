import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/glassmorphismContainer.dart';

class HomeView2 extends StatelessWidget {
  const HomeView2.HomeView({super.key});

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  void _showGroupList(BuildContext context) {
    List<String> groupNames = [
      "Front de Libération Nationale (FLN)",
      "Rassemblement National Démocratique (RND)",
      "Mouvement de la Société pour la Paix (MSP)",
      "Mouvement El Islah (El Islah)",
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parliamentary Groups',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: groupNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.asset(
                        'assets/groupe_parlementaire/gp${index + 1}.png',
                        width: 40,
                        height: 40,
                      ),
                      title: Text(
                        groupNames[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
                      'Explore',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 20),
                    child: Text(
                      '7 September 2024',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              _buildCarouselSlider(context),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parliamentary groups',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      child: FloatingActionButton(
                        foregroundColor: Colors.white,
                        splashColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        hoverColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          _showGroupList(context);
                        },
                        tooltip: 'more',
                        mini: false,
                        child: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ],
                ),
              ),
              _buildParliamentaryGroupsCarousel(context),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'News',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              ..._buildNewsUpdates(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSlider(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: [
        'assets/images/welcome_1.jpg',
        'assets/images/welcome_2.jpg',
        'assets/images/welcome_3.jpg',
      ].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  i,
                  fit: BoxFit.cover,
                  width: 1000,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildParliamentaryGroupsCarousel(BuildContext context) {
    List<String> groupNames = [
      "Front de Libération Nationale (FLN)",
      "Rassemblement National Démocratique (RND)",
      "Mouvement de la Société pour la Paix (MSP)",
      "Mouvement El Islah (El Islah)",
    ];

    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 180,
        autoPlay: false,
        enlargeCenterPage: true,
      ),
      itemCount: groupNames.length,
      itemBuilder: (BuildContext context, int index, int realIdx) {
        return _buildGlassmorphicContainer(
          context: context,
          height: 150,
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Image(
                  width: 50,
                  height: 50,
                  image: AssetImage('assets/groupe_parlementaire/gp${index + 1}.png'),
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    groupNames[index],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildNewsUpdates(BuildContext context) {
    List<String> newsTitles = [
      'Elections are coming up soon',
      '440 parliamentry seats',
      'Elections may take another turn',
    ];

    return List.generate(newsTitles.length, (index) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/news_${index + 1}.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  newsTitles[index],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGlassmorphicContainer({
    required BuildContext context,
    required double width,
    required double height,
    String? additionalText,
    String? image,
    Widget? child,
    BoxFit? fit,
  }) {
    return glassmorphicContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (child != null) child,
          if (image != null)
            Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 50);
              },
            ),
          if (additionalText != null)
            Padding(
              padding: const EdgeInsets.all(0.0),
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
  }
}
