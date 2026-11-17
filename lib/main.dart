import 'package:fit_track_pro/features/auth/screens/auth_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:fit_track_pro/features/auth/screens/login_screen.dart';
import 'package:fit_track_pro/features/workouts/screens/home_screen.dart';
import 'package:fit_track_pro/examen3/weight_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit Track Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      //home: const AuthCheckScreen(),
      home: const WeightScreen(),
      //home: const HomeScreen(),
    );
  }
}

