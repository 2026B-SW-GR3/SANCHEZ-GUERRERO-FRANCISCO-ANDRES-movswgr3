import 'package:flutter/material.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_text_styles.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const AirbnbCloneApp());
}

class AirbnbCloneApp extends StatelessWidget {
  const AirbnbCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airbnb · Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.rausch,
          primary: AppColors.rausch,
          surface: AppColors.canvas,
        ),
        textTheme: AppTextStyles.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
