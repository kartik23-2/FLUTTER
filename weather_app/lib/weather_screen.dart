import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class ForecastEntry {
  final DateTime dateTime;
  final double tempCelsius;
  final int weatherCode;

  ForecastEntry({
    required this.dateTime,
    required this.tempCelsius,
    required this.weatherCode,
  });
}

class WeatherData {
  final String city;
  final double tempCelsius;
  final String condition;
  final int weatherCode;
  final int humidity;
  final double windSpeedKmh;
  final double feelsLikeCelsius;
  final List<ForecastEntry> forecast;

  WeatherData({
    required this.city,
    required this.tempCelsius,
    required this.condition,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeedKmh,
    required this.feelsLikeCelsius,
    required this.forecast,
  });
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController(
    text: 'London',
  );
  Future<WeatherData>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = getWeatherForCity(_cityController.text.trim());
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<WeatherData> getWeatherForCity(String city) async {
    final encodedCity = Uri.encodeComponent(city);
    final currentWeatherUri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$encodedCity&appid=$OpenWeatherAPIKey&units=metric',
    );
    final forecastUri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$encodedCity&appid=$OpenWeatherAPIKey&units=metric',
    );

    try {
      final responses = await Future.wait([
        http.get(currentWeatherUri),
        http.get(forecastUri),
      ]);

      final currentResponse = responses[0];
      final forecastResponse = responses[1];

      if (currentResponse.statusCode != 200) {
        final errorBody = jsonDecode(currentResponse.body);
        final message =
            errorBody['message'] ?? 'Unable to fetch current weather';
        throw Exception(message.toString());
      }

      if (forecastResponse.statusCode != 200) {
        final errorBody = jsonDecode(forecastResponse.body);
        final message = errorBody['message'] ?? 'Unable to fetch forecast';
        throw Exception(message.toString());
      }

      final currentData = jsonDecode(currentResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);

      final forecastList = (forecastData['list'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final dailyForecast = <ForecastEntry>[];
      final seenDays = <String>{};

      for (final item in forecastList) {
        final dateTime = DateTime.parse(item['dt_txt'] as String).toLocal();
        final dayKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

        if (seenDays.contains(dayKey)) {
          continue;
        }

        seenDays.add(dayKey);
        dailyForecast.add(
          ForecastEntry(
            dateTime: dateTime,
            tempCelsius: (item['main']['temp'] as num).toDouble(),
            weatherCode: item['weather'][0]['id'] as int,
          ),
        );

        if (dailyForecast.length == 5) {
          break;
        }
      }

      return WeatherData(
        city: (currentData['name'] as String?) ?? city,
        tempCelsius: (currentData['main']['temp'] as num).toDouble(),
        condition: currentData['weather'][0]['main'] as String,
        weatherCode: currentData['weather'][0]['id'] as int,
        humidity: currentData['main']['humidity'] as int,
        windSpeedKmh: ((currentData['wind']['speed'] as num).toDouble() * 3.6),
        feelsLikeCelsius: (currentData['main']['feels_like'] as num).toDouble(),
        forecast: dailyForecast,
      );
    } catch (e) {
      throw Exception('Error fetching weather for "$city": $e');
    }
  }

  IconData _iconForWeatherCode(int code) {
    if (code >= 200 && code < 300) {
      return Icons.thunderstorm_rounded;
    }
    if (code >= 300 && code < 600) {
      return Icons.grain_rounded;
    }
    if (code >= 600 && code < 700) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 700 && code < 800) {
      return Icons.blur_on_rounded;
    }
    if (code == 800) {
      return Icons.wb_sunny_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }

  void _searchCity() {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _weatherFuture = getWeatherForCity(city);
    });
  }

  String _shortDayName(DateTime dateTime) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dateTime.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _searchCity,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchCity(),
                    decoration: const InputDecoration(
                      labelText: 'City name',
                      hintText: 'Enter a city (e.g. London)',
                      prefixIcon: Icon(Icons.location_city_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _searchCity,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<WeatherData>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Could not fetch weather data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _searchCity,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data;
                  if (data == null) {
                    return const Center(child: Text('No weather data found'));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 10,
                            margin: const EdgeInsets.all(4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      data.city,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Icon(
                                      _iconForWeatherCode(data.weatherCode),
                                      size: 64,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${data.tempCelsius.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data.condition,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Weather Forecast',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: data.forecast
                                .map(
                                  (item) => Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _shortDayName(item.dateTime),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Icon(
                                            _iconForWeatherCode(
                                              item.weatherCode,
                                            ),
                                            size: 32,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${item.tempCelsius.toStringAsFixed(0)}°C',
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Additional weather details',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _DetailCard(
                                  icon: Icons.opacity_rounded,
                                  label: 'Humidity',
                                  value: '${data.humidity}%',
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: _DetailCard(
                                  icon: Icons.air_rounded,
                                  label: 'Wind Speed',
                                  value:
                                      '${data.windSpeedKmh.toStringAsFixed(1)} km/h',
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _DetailCard(
                                  icon: Icons.thermostat_rounded,
                                  label: 'Feels Like',
                                  value:
                                      '${data.feelsLikeCelsius.toStringAsFixed(1)}°C',
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
