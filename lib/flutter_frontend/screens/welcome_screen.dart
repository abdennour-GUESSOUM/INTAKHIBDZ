import 'dart:convert';
import 'package:INTAKHIB/flutter_frontend/screens/views/home_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/results_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/settings_view.dart';
import 'package:INTAKHIB/flutter_frontend/screens/views/vote_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';



class WelcomeScreen extends StatefulWidget {
  final Uint8List? profileImage;


  const WelcomeScreen({Key? key, this.profileImage}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;

  Uint8List? _persistentImage;

  final PageController _pageController = PageController();

  @override
  @override
  void initState() {
    super.initState();
    _loadImage;
  }

  Future<void> _saveImage(Uint8List image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String base64Image = base64Encode(image);
    await prefs.setString('profile_image', base64Image);
  }
  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString('profile_image');
    if (base64Image != null) {
      setState(() {
        _persistentImage = base64Decode(base64Image);
      });
    } else if (widget.profileImage != null) {
      _persistentImage = widget.profileImage;
      await _saveImage(widget.profileImage!);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromRadius(40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16 , 0,16,0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('INTAKHIB', style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary)),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _persistentImage != null
                          ? MemoryImage(_persistentImage!)
                          : AssetImage("assets/abdou.jpg") as ImageProvider<Object>,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                onPressed: () {
                  if (kDebugMode) {
                    print('Rounded icon pressed');
                  }
                },
              ),
              actions: [
                Container(
                  width: 40,
                  height: 50,
                  child: SvgPicture.asset(
                    "assets/flag.svg",
                    fit: BoxFit.contain,  // This ensures the SVG is scaled properly within the container
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              children:   [
                Center(child: HomeView2.HomeView()),
                Center(child: Voteview()),
                Center(child: ResultsView()),
                Center(child: SettingsView()),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Theme.of(context).colorScheme.primary.withOpacity(.50),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Theme.of(context).colorScheme.secondary,
                hoverColor: Theme.of(context).colorScheme.secondary,
                gap: 8,
                activeColor:Theme.of(context).colorScheme.secondary,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor:Theme.of(context).colorScheme.background,
                color: Theme.of(context).colorScheme.primary,
                tabs: const [
                  GButton(
                    icon: LineIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.how_to_vote_outlined,
                    text: 'Vote',
                  ),
                  GButton(
                    icon: LineIcons.voteYea,
                    text: 'Results',
                  ),
                  GButton(
                    icon: Icons.settings,
                    text: 'Settings',
                  ),

                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _pageController.animateToPage(
                    _selectedIndex,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuad,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

