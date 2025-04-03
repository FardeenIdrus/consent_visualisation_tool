// lib/model/home_model.dart
import 'package:flutter/material.dart';

/// Represents a menu item on the home screen with a title, description, route, and icon.
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

/// Model for the home screen that holds a list of available menu items.
class HomeScreenModel {
  // List of menu items to be displayed on the home screen.
  final List<HomeMenuItem> menuItems = [
    HomeMenuItem(
      title: 'Compare',
      description: 'Compare different consent models',
      routeName: '/compare',
      icon: Icons.compare_arrows,
    ),
    HomeMenuItem(
      title: 'Chat',
      description: 'Experience consent models in a simulated chat interface',
      routeName: '/simulation',
      icon: Icons.chat_bubble_outline,
    ),
  ];
}