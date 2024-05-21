import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../utils/identity_card.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
            children: const [
              Padding(
                padding: EdgeInsets.all(0), // Adjust the padding as needed
                child: Align(
                  alignment: Alignment.topCenter, // Changed to topCenter for slight lower positioning
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: IDCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
