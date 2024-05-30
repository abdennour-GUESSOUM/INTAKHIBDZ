import 'package:INTAKHIB/flutter_frontend/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

class InfographicScreen extends StatefulWidget {
  @override
  _InfographicScreenState createState() => _InfographicScreenState();
}

class _InfographicScreenState extends State<InfographicScreen> {
  ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          _isAtBottom = true;
        });
      } else {
        setState(() {
          _isAtBottom = false;
        });
      }
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Image.asset('assets/infographic.jpg'),
      ),
      floatingActionButton: _isAtBottom
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, _createRoute());
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
