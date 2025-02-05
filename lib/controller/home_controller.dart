// lib/controller/home_screen_controller.dart
import 'package:consent_visualisation_tool/model/home_model.dart';
import 'package:consent_visualisation_tool/view/compare_view.dart';
import 'package:flutter/material.dart';


class HomeController {
  // Create an instance of HomeScreenModel
  final homeScreenModel = HomeScreenModel();

  void navigateToSection(BuildContext context, String routeName) {
    switch (routeName) {
      // case '/experiment':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ExperimentScreen()),
      //   );
      //   break;
      case '/compare':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompareScreen()),
        );
        break;
      default:
        break;
    }
  }
}