import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../utils/glassmorphismContainer.dart';



class HomeView2 extends StatelessWidget {
  const HomeView2({super.key});

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
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
                      'Elections start',
                      style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 20),
                    child: Text(
                      '7 september 2024',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.start,
                    ),
                  ),

                ],
              ),
              _buildHorizontalList(context),
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
                        splashColor: Theme.of(context).colorScheme.primary,

                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        hoverColor: Theme.of(context).colorScheme.primary,
                        onPressed: (){},
                        tooltip: 'more',
                        mini: false, // Set mini to true to reduce the size
                        child:  Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ],
                ),
              ),
              _buildMiniHorizontalList(context),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'News',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color:Theme.of(context).colorScheme.primary,
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

  Widget _buildHorizontalList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => _buildGlassmorphicContainer(
          fit: BoxFit.contain,
          context: context,
          height: 100,
          width: 260,
          image: 'assets/images/welcome_${index + 1}.jpg',  // Placeholder for image assets
        ),
      ),
    );
  }
  Widget _buildMiniHorizontalList(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          String additionalText;
          switch (index) {
            case 0:
              additionalText = "Front de Libération Nationale (FLN)";
              break;
            case 1:
              additionalText = "Rassemblement National Démocratique (RND)";
              break;
            case 2:
              additionalText = "Mouvement de la Société pour la Paix (MSP)";
              break;
            case 3:
              additionalText = "Mouvement El Islah (El Islah)";
              break;
            case 4:
              additionalText = "groupe parlementaire";
              break;
            default:
              additionalText = "";
          }
          return _buildGlassmorphicContainer(
            context: context,
            height: 150,
            width: 150,
            child: Column(
              children: [
                Image(
                  width: 50,
                  height: 50,
                  image: AssetImage('assets/groupe_parlementaire/gp${index + 1}.png'),
                  fit: BoxFit.contain,  // This ensures the SVG is scaled properly within the container


                ),
                const SizedBox(height: 25), // Adding some spacing
                Center(
                  child: Text(
                    additionalText,
                    style: const TextStyle(fontSize: 12  , fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    // Adjust the font size here
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildNewsUpdates(BuildContext context) {
    List<String> newsTitles = [
      'Flutter 3.0 Released!',
      'Dart 3 Updates: What’s New?',
      'Top 10 Flutter Packages of 2024',
    ];

    return List.generate(newsTitles.length, (index) => _buildGlassmorphicContainer(
      context: context,
      height: 180,
      width: double.infinity,
      image: 'assets/images/news_${index + 1}.jpg',
      fit: BoxFit.contain,  // This ensures the SVG is scaled properly within the container


    ));
  }

  Widget _buildGlassmorphicContainer({
    required BuildContext context,
    required double width,
    required double height,
    String? additionalText,
    String? image, // Make image optional
    Widget? child,
    BoxFit? fit, // Make child widget optional
  }) {
    return glassmorphicContainer(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (child != null) // Render the child widget if provided
            child ,
          if (image != null) // Render the image if provided
            Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height * 1,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 50); // Placeholder for error cases
              },
            ),
          if (additionalText != null) // Render additional text if provided
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
