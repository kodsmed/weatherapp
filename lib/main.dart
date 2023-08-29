import 'package:flutter/material.dart';

// import extracted pages
import 'current_weather_page.dart';
import 'five_day_forecast_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

// imports for the settings disk storage
import 'util/read_write_to_disk.dart';

// imports for the settings global state
import 'package:provider/provider.dart';
import 'util/settings_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        // Set the primary color theme of the app.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        useMaterial3: true,
        // Set the bottom navbar theme.
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.grey[700],
          indicatorColor: Colors.white,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      home: const MainPage(title: 'Current Weather'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> content = [];
  int _currentPageIndex = 3;
  bool _internationalLanguage = false;
  var settingsModel;

  void addContent(BuildContext context) {
    if (content.isNotEmpty) {
      return;
    }
    content.add(const CurrentWeatherPage());
    content.add(const FiveDayForecastPage());
    content.add(const SettingsPage());
    content.add(const AboutPage());
  }

  @override
  void initState() {
    super.initState();
    loadInitialPage();
  }

  @override
  void didChangeDependencies() {
    settingsModel = Provider.of<SettingsModel>(context);
    _internationalLanguage = settingsModel.internationalLanguage;
    super.didChangeDependencies();
  }

  void loadInitialPage() async {
    // load the settings from disk
    final settingsData = await loadNonSensitiveSettings();
    final apiKey = await loadSensitiveSettings();

    // update the settings in the provider
    final settingsModel = Provider.of<SettingsModel>(context, listen: false);
    settingsModel.updateSettings(
      internationalLanguage: settingsData['internationalLanguage'] ?? false,
      imperialUnits: settingsData['imperialUnits'] ?? false,
      useYrApi: settingsData['useYrApi'] ?? false,
      apiKey: apiKey ?? '',
    );

    // check if we have an international language
    if (settingsData['internationalLanguage'] == true) {
      // if we do, then we need to update the language
      setState(() {
        _internationalLanguage = true;
      });
    } else {
      // otherwise we can show the current weather page
      setState(() {
        _internationalLanguage = false;
      });
    }

    // check if we have an API key
    if (settingsData['useYrApi'] == false &&
        (apiKey == null || apiKey.isEmpty || apiKey == '')) {
      // if we don't have an API key and we are not using Yr.no API
      // then we need to show the settings page
      setState(() {
        _currentPageIndex = 2;
      });
    } else {
      // otherwise we can show the current weather page
      setState(() {
        _currentPageIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    addContent(context);

    settingsModel = Provider.of<SettingsModel>(context);
    _internationalLanguage = settingsModel.internationalLanguage;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.my_location),
            label: _internationalLanguage ? 'Current Weather' : 'Väder',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today),
            label: _internationalLanguage ? '5 Day Forecast' : '5 Dygn Prognos',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: _internationalLanguage ? 'Settings' : 'Inställningar',
          ),
          NavigationDestination(
            icon: const Icon(Icons.info),
            label: _internationalLanguage ? 'About' : 'Om',
          ),
        ],
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          if (index != _currentPageIndex) {
            setState(() {
              _currentPageIndex = index;
            });
          }
        },
      ),
      body: content.elementAt(_currentPageIndex),
    );
  }
}
