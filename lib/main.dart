import 'package:flutter/material.dart';
import '/view/home_view.dart';
import '/Theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consent Models Educational Platform',
      theme: AppTheme.lightTheme(), // Use the theme here
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
