import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter Web uchun zarur
  await dotenv.load(fileName: 'assets/.env'); // assets ichidan .env fayl yuklanadi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ob-Havo Ilovasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? _city;
  String? _weather;

  Future<void> fetchWeather(String city) async {
    final apiKey = dotenv.env['API_KEY']; // .env dan API_KEY ni yuklash
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=uz';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather =
              "${data['weather'][0]['description']}, ${data['main']['temp']}°C";
        });
      } else {
        setState(() {
          _weather = "Xato: shahar topilmadi.";
        });
      }
    } catch (e) {
      setState(() {
        _weather = "Xato: Internetga ulanishni tekshiring.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ob-Havo Ilovasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Shahar nomini kiriting',
              ),
              onChanged: (value) {
                _city = value;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_city != null && _city!.isNotEmpty) {
                  fetchWeather(_city!);
                }
              },
              child: const Text('Ob-havoni tekshirish'),
            ),
            const SizedBox(height: 32),
            if (_weather != null)
              Text(
                _weather!,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
