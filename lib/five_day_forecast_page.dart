import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// imports for the settings global state
import 'package:provider/provider.dart';
import 'util/settings_provider.dart';

// imports for the location
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// import dynamic weather icons
import 'package:dynamic_weather_icons/dynamic_weather_icons.dart';

class FiveDayForecastPage extends StatefulWidget {
  const FiveDayForecastPage({super.key});

  @override
  State<FiveDayForecastPage> createState() => _FiveDayForecastPageState();
}

class _FiveDayForecastPageState extends State<FiveDayForecastPage> {
  Map<String, dynamic> _forecastWeatherData = {};
  bool _isLoading = false;
  bool _isDisposed = false;
  var settingsModel;
  String locationLat = '57.9246';
  String locationLon = '12.5277';
  var lastUpdated;
  String unitStringShort = 'C';

  //make it scrollable
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    lastUpdated = DateTime(1700, 1, 1, 0, 0, 0, 0, 0);
  }

  @override
  void didChangeDependencies() {
    settingsModel = Provider.of<SettingsModel>(context);
    _fetchFiveDayForecast();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _updateLocation() async {
    if (_isDisposed) {
      return;
    }
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!_isDisposed) {
        setState(() {
          locationLat = '${position.latitude}';
          locationLon = '${position.longitude}';
        });
      }
    } else {
      if (!_isDisposed) {
        setState(() {
          locationLat = '57.9246';
          locationLon = '12.5277';
        });
      }
    }

    return;
  }

  void _fetchFiveDayForecast() async {
    // check if we are already loading data to avoid multiple requests
    if (_isLoading) {
      return;
    }

    // Check if we have data that is less than 15 min old.
    if (_forecastWeatherData.isNotEmpty) {
      var now = DateTime.now();
      var difference = now.difference(lastUpdated);
      if (difference.inMinutes < 15) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    String langString = settingsModel.internationalLanguage ? 'en' : 'se';
    String unitString = settingsModel.imperialUnits ? 'imperial' : 'metric';
    unitStringShort = settingsModel.imperialUnits ? 'F' : 'C';
    String apiKey = settingsModel.apiKey;
    if (apiKey.isEmpty) {
      print('API key is empty');
      return;
    }
    await _updateLocation();

    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$locationLat&lon=$locationLon&appid=$apiKey&units=$unitString&lang=$langString');
    var response = await http.get(url);
    if (response.statusCode == 200 && !_isDisposed) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        _forecastWeatherData = jsonResponse;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    lastUpdated = DateTime.now();
    if (!_isDisposed) {
          setState(() {
      _isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_forecastWeatherData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      int timeZoneCorrectionHours =
          _forecastWeatherData['city']['timezone'] ~/ 3600;
      return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    _forecastWeatherData['city']['name'],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // map through the list of forecasts and create a widget for each
                        for (var forecast in _forecastWeatherData['list']) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // add a border to the bottom of each forecast
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(height: 16),
                                Column(
                                  children: [
                                    Text(
                                      '${forecast['dt_txt'].toString().substring(0, 10)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      // the forcast is in UTC, so we need to add 2 hours to get the correct time
                                      // and then we only want the time part of the string
                                      // we also want to add 3 hours to mark the interval.
                                      '${DateTime.parse(forecast['dt_txt']).add(Duration(hours: timeZoneCorrectionHours)).toString().substring(11, 16)} - ${DateTime.parse(forecast['dt_txt']).add(Duration(hours: timeZoneCorrectionHours + 3)).toString().substring(11, 16)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(children: [
                                  Text(
                                      '${forecast['weather'][0]['description']}'),
                                  Text(
                                      '${forecast['main']['temp'].toStringAsFixed(0)}°$unitStringShort'),
                                ]),
                                // If the weather code is 200-299 then it is a thunderstorm
                                if (forecast['weather'][0]['id'] >= 200 &&
                                    forecast['weather'][0]['id'] < 300)
                                  Icon(
                                    WeatherIcon.getIcon('wi-thunderstorm'),
                                    size: 32,
                                  ),
                                // If the weather code is 300-399 then it is a drizzle
                                if (forecast['weather'][0]['id'] >= 300 &&
                                    forecast['weather'][0]['id'] < 400)
                                  Icon(
                                    WeatherIcon.getIcon('wi-sprinkle'),
                                    size: 32,
                                  ),
                                // If the weather code is 500-599 then it is rain
                                if (forecast['weather'][0]['id'] >= 500 &&
                                    forecast['weather'][0]['id'] < 600)
                                  Icon(
                                    WeatherIcon.getIcon('wi-rain'),
                                    size: 32,
                                  ),
                                // If the weather code is 600-699 then it is snow
                                if (forecast['weather'][0]['id'] >= 600 &&
                                    forecast['weather'][0]['id'] < 700)
                                  Icon(
                                    WeatherIcon.getIcon('wi-snow'),
                                    size: 32,
                                  ),
                                // If the weather code is 700-799 then it is fog
                                if (forecast['weather'][0]['id'] >= 700 &&
                                    forecast['weather'][0]['id'] < 800)
                                  Icon(
                                    WeatherIcon.getIcon('wi-fog'),
                                    size: 32,
                                  ),
                                // If the weather code is 800 then it is clear
                                if (forecast['weather'][0]['id'] == 800)
                                  // If it is night time, show the moon
                                  if (forecast['sys']['pod'] == 'n')
                                    Icon(
                                      WeatherIcon.getIcon('wi-night-clear'),
                                      size: 32,
                                    )
                                  // If it is day time, show the sun
                                  else
                                    Icon(
                                      WeatherIcon.getIcon('wi-day-sunny'),
                                      size: 32,
                                    ),
                                // If the weather code is 801-899 then it is clouds
                                if (forecast['weather'][0]['id'] >= 801 &&
                                    forecast['weather'][0]['id'] < 900)
                                  // If it is night time, show the moon
                                  if (forecast['sys']['pod'] == 'n')
                                    Icon(
                                      WeatherIcon.getIcon(
                                          'wi-night-alt-cloudy'),
                                      size: 32,
                                    )
                                  // If it is day time, show the sun
                                  else
                                    Icon(
                                      WeatherIcon.getIcon('wi-day-cloudy'),
                                      size: 32,
                                    ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
    }
  }
}
