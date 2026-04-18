import 'package:flutter/material.dart';
import 'package:weather_app/weather_screen.dart'; //both ways are correct as weather_screen.dart is in the same directory as main.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Weather App',
       home: const WeatherScreen(),
       debugShowCheckedModeBanner: false,
       theme: ThemeData.dark().copyWith(  
        scaffoldBackgroundColor: const Color.fromARGB(255, 8, 9, 10),
        ), // Set the background color to light blue but it is not working because the scaffold background color is overridden by the default theme of the app which is dark theme. To fix this, we can set the scaffold background color to light blue in the dark theme as well.

        
      // Scaffold(
      //   appBar:  AppBar(
      //     title: const Text('Weather App'),
      //   ),
      //   body: Center(
      //     child: const Text('Hello, World!'),
      //   ),
      // ),
    );
  }
}