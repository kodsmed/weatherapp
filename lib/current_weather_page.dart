import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// imports for the settings global state
import 'package:provider/provider.dart';
import 'util/settings_provider.dart';

// imports for the location
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

//import the wind direction arrow
import 'util/wind_direction.dart';

class CurrentWeatherPage extends StatefulWidget {
  const CurrentWeatherPage({super.key});

  @override
  State<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  Map<String, dynamic> _currentWetherData = {};
  bool _isLoading = false;
  String locationLat = '57.9246';
  String locationLon = '12.5277';
  var settingsModel;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    settingsModel = Provider.of<SettingsModel>(context);
    _fetchCurrentWeather();
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

  void _fetchCurrentWeather() async {
    if (_isDisposed) {
      return;
    }
    // check if we are already loading data to avoid multiple requests
    if (_isLoading) {
      return;
    }

    // Check if we have data that is less than 15 min old.
    if (_currentWetherData.isNotEmpty) {
      var now = DateTime.now();
      var lastUpdated =
          DateTime.fromMillisecondsSinceEpoch(_currentWetherData['dt'] * 1000);
      var difference = now.difference(lastUpdated);
      if (difference.inMinutes < 15) {
        return;
      }
    }
    if (!_isDisposed) {
      setState(() {
        _isLoading = true;
      });
    }
    // if international language is selected, use english else use swedish
    String langString = settingsModel.internationalLanguage ? 'en' : 'se';
    String unitString = settingsModel.imperialUnits ? 'imperial' : 'metric';
    String apiKey = settingsModel.apiKey;
    if (apiKey.isEmpty) {
      print('API key is empty');
      return;
    }
    await _updateLocation();

    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$locationLat&lon=$locationLon&appid=$apiKey&units=$unitString&lang=$langString');
    var response = await http.get(url);
    if (response.statusCode == 200 && !_isDisposed) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        _currentWetherData = jsonResponse;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
      print('url: $url');
    }
    if (!_isDisposed) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentWetherData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      var timezoneShiftSeconds = _currentWetherData['timezone'];
      var dateTime =
          DateTime.fromMillisecondsSinceEpoch(_currentWetherData['dt'] * 1000)
              .add(Duration(seconds: timezoneShiftSeconds));
      String unitString = settingsModel.imperialUnits ? 'F' : '°C';
      String windSpeedUnitString = settingsModel.imperialUnits ? 'mph' : 'm/s';
      String rangeTextString =
          settingsModel.internationalLanguage ? 'sensors in the area report' : 'mätstationer i området rapporterar';
      double? tempMin = _currentWetherData['main']['temp_min']?.toDouble();
      double? tempMax = _currentWetherData['main']['temp_max']?.toDouble();
      String? tempMinString = tempMin?.toStringAsFixed(1);
      String? tempMaxString = tempMax?.toStringAsFixed(1);

      double temp = _currentWetherData['main']['temp'].toDouble();
      String tempString = temp.toStringAsFixed(1);

      double feelsLikeTemp = _currentWetherData['main']['feels_like'].toDouble();
      String feelsLikeTempString = feelsLikeTemp.toStringAsFixed(1);
      String feelsLikeTextString =
          settingsModel.internationalLanguage ? ', feels like' : ', känns som';

      String windTextString = settingsModel.internationalLanguage ? 'Wind' : 'Vind';
      double windSpeed = _currentWetherData['wind']['speed'];
      double windDirection = _currentWetherData['wind']['deg'].toDouble();
      String windSpeedString = windSpeed.toStringAsFixed(1);
      double? windGust = _currentWetherData['wind']['gust']?.toDouble();
      String? windGustString = windGust?.toStringAsFixed(1);
      String windGustTextString =
          settingsModel.internationalLanguage ? 'Gust' : 'Byar';
      String windDirectionString = getCompassDirection(windDirection, settingsModel.internationalLanguage ? 'en' : 'sv');
      String lastUpdatedTextString = settingsModel.internationalLanguage
          ? 'Data last updated'
          : 'Data senast uppdaterad';

      int imageCode = _currentWetherData['weather'][0]['id'];
      // if the weathercode is under 800 round it down to the closest 100
      if (imageCode < 800 ) {
        imageCode = (imageCode / 100).floor() * 100;
      }

      return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/$imageCode.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Container(

              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                        const SizedBox(height: 16),
                        Text(
                          _currentWetherData['name'],
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          _currentWetherData['weather'][0]['description'],
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '$tempString$unitString $feelsLikeTextString $feelsLikeTempString$unitString',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (tempMin != null && tempMax != null)
                          Text(
                            '$rangeTextString $tempMinString - $tempMaxString$unitString',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text(
                            '$windTextString: $windSpeedString $windSpeedUnitString',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(width: 16),
                          if (windGust != null)
                          Text(
                            '$windGustTextString: $windGustString $windSpeedUnitString',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          WindDirectionArrow(
                            windDirection: windDirection, key: UniqueKey()),
                          Text('$windDirectionString', style: Theme.of(context).textTheme.headlineSmall),
                        ]),
                      Text(
                        '$lastUpdatedTextString: ${dateTime.toString().substring(0, 16)}'),
                      const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],),
              ))
              ]);
    } // else
  }
}
