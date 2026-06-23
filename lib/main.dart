// Lab assignment 6 - Web API
// Group: Colin Schulte, Dylan Schulte
// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lab_assignment_6/weather_service.dart';

void main() async {
  // Load api key
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _cityController = TextEditingController();
  Future<Map<String, dynamic>>? _futureWeather;

  // Helper function to fetch the weather and set weather state
  void searchWeather() {
    setState(() {
      _futureWeather = WeatherService().fetchWeather(
        _cityController.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weather App",
      home: Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // City input text field
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Button to get weather
              ElevatedButton(
                onPressed: searchWeather,
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 16),
              // Display city weather
              _futureWeather == null
                  ? const Text("Enter a city")
                  : FutureBuilder<Map<String, dynamic>>(
                      future: _futureWeather,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final weather = snapshot.data!;
                          // Get icon data
                          final icon = weather["weather"][0]["icon"];
                          final iconUrl =
                              'https://openweathermap.org/img/wn/$icon@2x.png';

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Main weather conditions
                              Image.network(iconUrl, width: 100, height: 100),
                              Text(weather['name']),
                              Text('${weather['main']['temp']} °C'),
                              Text(weather['weather'][0]['description']),

                              // Addition weather information
                              Text(
                                'Min temp: ${weather['main']['temp_min']} °C',
                              ),
                              Text(
                                'Max temp: ${weather['main']['temp_max']} °C',
                              ),
                              Text(
                                'Feels like ${weather['main']['feels_like']} °C',
                              ),
                              Text('Humidity: ${weather['main']['humidity']}%'),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        // Data is loading
                        return const CircularProgressIndicator();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
