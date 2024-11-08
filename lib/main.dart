import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ValidationScreen(),
        '/select': (context) => CustomSelectScreen(),
        '/image': (context) => ImageScreen(),
        '/weather': (context) => WeatherScreen(),
      },
    );
  }
}

class ValidationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validation Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email TextField
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // Password TextField
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.pushNamed(context, '/select');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSelectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an Option'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show Image Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/image');
              },
              child: Text('Show Image'),
            ),
            SizedBox(height: 20),

            // Show Weather Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/weather');
              },
              child: Text('Show Weather'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Screen'),
      ),
      body: Center(
        child: Image.asset(
          'asset/download.jpeg',
          height: 300,
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String apiKey = '0681db21d3ee613fd7ad551a4140a92e';
  String location = 'New York';
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeatherData(location); // Initially load weather for default location
  }

  // Fetch weather data for the specified city
  Future<void> fetchWeatherData(String city) async {
    final url = Uri.parse(
        'http://api.weatherstack.com/current?access_key=$apiKey&query=$city');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == false || data['current'] == null) {
          setState(() {
            isLoading = false;
            errorMessage = 'Error: ${data['error']['info']}';
          });
        } else {
          setState(() {
            weatherData = data;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data (HTTP ${response.statusCode})';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $error';
      });
    }
  }

  // Handle search button press
  void _searchCity() {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      fetchWeatherData(_cityController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextField to search for a city
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _searchCity,
              child: Text('Search'),
            ),
            SizedBox(height: 20),

            // Displaying weather data or loading state
            isLoading
                ? CircularProgressIndicator()
                : weatherData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Weather in ${weatherData!['location']['name']}, ${weatherData!['location']['country']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Temperature: ${weatherData!['current']['temperature']}°C',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Feels Like: ${weatherData!['current']['feelslike']}°C',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Humidity: ${weatherData!['current']['humidity']}%',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Wind Speed: ${weatherData!['current']['wind_speed']} km/h',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Pressure: ${weatherData!['current']['pressure']} hPa',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Visibility: ${weatherData!['current']['visibility']} km',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'UV Index: ${weatherData!['current']['uv_index']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Sunrise: ${weatherData!['current']['sunrise']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Sunset: ${weatherData!['current']['sunset']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 20),
                          Image.network(
                            weatherData!['current']['weather_icons'][0],
                            height: 100,
                            width: 100,
                          ),
                        ],
                      )
                    : Text(
                        errorMessage,
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
          ],
        ),
      ),
    );
  }
}
