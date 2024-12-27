import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  // Example: Tunis _latitude et _longitude
  final double _latitude = 33.886917;
  final double _longitude = 9.537499;

  void _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _weatherService.fetchWeather(_latitude, _longitude);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Impossible de récupérer les données météorologiques.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Météo'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _weatherData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ville : Tunis',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Température : ${_weatherData!['current_weather']['temperature']} °C',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Conditions : ${_weatherData!['current_weather']['weathercode']}',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                )
              : Center(child: Text('Aucune donnée disponible')),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeather,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
