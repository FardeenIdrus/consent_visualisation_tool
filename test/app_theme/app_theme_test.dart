// test/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consent_visualisation_tool/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme returns correct ThemeData with expected properties', () {
      final theme = AppTheme.lightTheme();
      
      // Test basic colors
      expect(theme.primaryColor, equals(AppTheme.primaryColor));
      expect(theme.scaffoldBackgroundColor, equals(AppTheme.backgroundColor));
      
      // Test color scheme
      expect(theme.colorScheme.primary, equals(AppTheme.primaryColor));
      expect(theme.colorScheme.secondary, equals(AppTheme.secondaryColor));
      expect(theme.colorScheme.background, equals(AppTheme.backgroundColor));
      
      // Test app bar theme - using backgroundColor for newer Flutter versions
      expect(theme.appBarTheme.backgroundColor, equals(AppTheme.backgroundColor));
      expect(theme.appBarTheme.elevation, equals(0));
      expect(theme.appBarTheme.iconTheme?.color, equals(AppTheme.textPrimaryColor));
      expect(theme.appBarTheme.titleTextStyle?.color, equals(AppTheme.textPrimaryColor));
      expect(theme.appBarTheme.titleTextStyle?.fontSize, equals(20));
      expect(theme.appBarTheme.titleTextStyle?.fontWeight, equals(FontWeight.bold));
      
      // Test text theme
      expect(theme.textTheme.displayLarge?.color, equals(AppTheme.textPrimaryColor));
      expect(theme.textTheme.displayLarge?.fontSize, equals(32));
      expect(theme.textTheme.displayMedium?.color, equals(AppTheme.textPrimaryColor));
      expect(theme.textTheme.bodyLarge?.color, equals(AppTheme.textSecondaryColor));
      expect(theme.textTheme.bodyLarge?.fontSize, equals(16));
      
      // Test card theme
      expect(theme.cardTheme.color, equals(Colors.white));
      expect(theme.cardTheme.elevation, equals(8));
      expect(theme.cardTheme.shadowColor, equals(Colors.black12));
      
      // Test elevated button theme
      final buttonStyle = theme.elevatedButtonTheme.style;
      // Test button background color
      final backgroundColor = buttonStyle?.backgroundColor?.resolve({});
      expect(backgroundColor, equals(AppTheme.primaryColor));
      
      // Test button foreground color
      final foregroundColor = buttonStyle?.foregroundColor?.resolve({});
      expect(foregroundColor, equals(Colors.white));
      
      // Test shape of button (indirectly testing the BorderRadius)
      final shape = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape, isA<RoundedRectangleBorder>());
    });

    test('cardDecoration returns BoxDecoration with correct properties', () {
      final decoration = AppTheme.cardDecoration();
      
      expect(decoration, isA<BoxDecoration>());
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, isA<BorderRadius>());
      
      // Test box shadow
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow![0].color, equals(Colors.black12));
      expect(decoration.boxShadow![0].blurRadius, equals(10));
      expect(decoration.boxShadow![0].offset, equals(const Offset(0, 4)));
    });

    test('gradientDecoration returns BoxDecoration with correct gradient', () {
      final decoration = AppTheme.gradientDecoration();
      
      expect(decoration, isA<BoxDecoration>());
      expect(decoration.gradient, isA<LinearGradient>());
      
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.begin, equals(Alignment.topLeft));
      expect(gradient.end, equals(Alignment.bottomRight));
      expect(gradient.colors.length, equals(2));
      
      // Test colors with opacity
      final color1 = gradient.colors[0];
      final color2 = gradient.colors[1];
      
      expect(color1, equals(AppTheme.primaryColor.withOpacity(0.8)));
      expect(color2, equals(AppTheme.secondaryColor.withOpacity(0.8)));
      
      // Test border radius
      expect(decoration.borderRadius, isA<BorderRadius>());
    });
    
    test('Color constants have expected values', () {
      expect(AppTheme.primaryColor, equals(const Color(0xFF4A90E2)));
      expect(AppTheme.secondaryColor, equals(const Color(0xFF5E35B1)));
      expect(AppTheme.backgroundColor, equals(const Color(0xFFF5F7FA)));
      expect(AppTheme.textPrimaryColor, equals(const Color(0xFF2C3E50)));
      expect(AppTheme.textSecondaryColor, equals(const Color(0xFF7F8C8D)));
    });
  });
}