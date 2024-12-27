import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?latitude=$latitude&longitude=$longitude&current_weather=true'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
