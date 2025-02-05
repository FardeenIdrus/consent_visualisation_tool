// lib/model/home_screen_model.dart
import 'package:flutter/material.dart';

class HomeMenuItem {
  final String title;
  final String description;
  final String routeName;
  final IconData icon;

  HomeMenuItem({
    required this.title,
    required this.description,
    required this.routeName,
    required this.icon,
  });
}

class HomeScreenModel {
  final List<HomeMenuItem> menuItems = [
    HomeMenuItem(
      title: 'Experiment',
      description: 'Interactive scenarios',
      routeName: '/experiment',
      icon: Icons.science,
    ),
    HomeMenuItem(
      title: 'Compare',
      description: 'Compare consent models',
      routeName: '/compare',
      icon: Icons.compare_arrows,
    ),
  ];
}