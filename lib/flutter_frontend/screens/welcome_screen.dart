import 'package:IntakhibDZ/flutter_frontend/screens/views/home_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/profile_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/settings_view.dart';
import 'package:IntakhibDZ/flutter_frontend/screens/views/vote_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';



class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isShown = true; // Add this line


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
              title: Text('INTAKHIBDZ', style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary)),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/abdou.jpg"),
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
              physics:  NeverScrollableScrollPhysics(),
              children:   [
                Center(child: HomeView2()),
                Center(child: Voteview()),
                Center(child: ProfileView()),
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
                    icon: LineIcons.identificationCard,
                    text: 'Profile',
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


