// lib/controller/home_controller.dart
import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../view/compare_view.dart';
import '../view/chat_interface_view.dart';

class HomeController {
  final homeScreenModel = HomeScreenModel();


  /// Navigates to a specific section of the app based on the provided route name.
  /// Supported routes include '/compare' for the comparison screen and '/simulation'
  /// for the chat simulation screen.

  void navigateToSection(BuildContext context, String routeName) {
    switch (routeName) {
      case '/compare':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompareScreen()),
        );
        break;
      case '/simulation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SimulationScreen()),
        );
        break;
    }
  }
}