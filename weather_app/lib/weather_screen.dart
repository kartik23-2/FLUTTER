import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<double>? _temperatureFuture;

  @override
  void initState() {
    super.initState();
    _temperatureFuture = getCurrentWeather();
  }

  Future<double> getCurrentWeather() async {
    try {
      String city = 'London';
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${OpenWeatherAPIKey}',
        ),
      );
      final data = jsonDecode(result.body);
      if (result.statusCode == 200) {
        final tempKelvin = data['main']['temp'];
        final tempCelsius = tempKelvin - 273.15;
        print('Temperature in $city: ${tempCelsius.toStringAsFixed(1)} C');
        return tempCelsius;
      } else {
        print('Failed to load weather data: ${result.statusCode}');
        print(result.body);
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      throw Exception('Error fetching weather');
    }
  }

  @override
  Widget build(BuildContext context) {
    String getDayName(int weekday) {
      const days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ];

      return days[weekday - 1];
    }

    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Weather App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // ignore: avoid_print
              print('Refresh button tapped');
            },
          ),
        ],
        // [GestureDetector(onTap:(){
        //     print('Refresh button tapped');
        // },
        //  child: const Icon( Icons.refresh, color: Colors.white,)
        //  )
        // ],                // gesture detector is another way to make the refresh button clickable
      ),
      body: Column(
        children: [
          //main card
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                // side: const BorderSide(color: Colors.white, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'london',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.wb_sunny,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: FutureBuilder<double>(
                          future: _temperatureFuture ??= getCurrentWeather(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (snapshot.hasError) {
                              return const Text(
                                'Failed to load',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }

                            final tempCelsius = snapshot.data ?? 0.0;
                            return Text(
                              '${tempCelsius.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Sunny', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Weather Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),

          //forecast cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                7,
                (index) => Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    // side: const BorderSide(color: Colors.white, width: 1),
                  ),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getDayName(
                            (now.weekday + index - 1) % 7 + 1,
                          ).substring(
                            0,
                            3,
                          ), //the problem with this is that it will go out of range when the index is greater than 6. To fix this, we can use the modulo operator to wrap around the days of the week.

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Icon(Icons.wb_sunny, size: 32, color: Colors.orange),
                        SizedBox(height: 10),
                        Text('${20 + index}°C', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Additional weather details',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: const [
                  Icon(Icons.opacity, size: 32, color: Colors.blue),
                  SizedBox(height: 8),
                  Text('Humidity', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    '60%',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.air, size: 32, color: Colors.green),
                  SizedBox(height: 8),
                  Text('Wind Speed', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    '15 km/h',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.thermostat, size: 32, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Feels Like', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    '27°C',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
