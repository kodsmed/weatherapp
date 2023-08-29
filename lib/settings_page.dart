import 'package:flutter/material.dart';

// imports for the settings global state
import 'package:provider/provider.dart';
import 'util/settings_provider.dart';

// imports for the settings disk storage
import 'util/read_write_to_disk.dart';

// imports for the clickable link to api signup
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _internationalLanguage = false;
  bool _imperialUnits = false;
  bool _useYrApi = false;
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _parseSettingsFromDisk();
    _parseApiKeyFromDisk();
  }

  Future<void> _parseSettingsFromDisk() async {
    var settingsData = await loadNonSensitiveSettings();

    setState(() {
      _internationalLanguage = settingsData['internationalLanguage'] ?? false;
      _imperialUnits = settingsData['imperialUnits'] ?? false;
      _useYrApi = settingsData['useYrApi'] ?? false;
    });
  }

  Future<void> _parseApiKeyFromDisk() async {
    var apiKey = await loadSensitiveSettings();
    print('apiKey: $apiKey');
    setState(() {
      _apiKey = apiKey ?? '';
    });
  }

  void _saveSettingsToDisk() async {
    // Save settings to the Provider
    var settingsModel = Provider.of<SettingsModel>(context, listen: false);
    settingsModel.updateSettings(
        internationalLanguage: _internationalLanguage,
        imperialUnits: _imperialUnits,
        useYrApi: _useYrApi,
        apiKey: _apiKey);

    // Save settings to disk
    await saveNonSensitiveDataToDisk(
      _internationalLanguage,
      _imperialUnits,
      _useYrApi,
    );
    await saveSensitiveSettings(_apiKey);
  }

  Future<void> _launchURL() async {
    const signUpUrl = 'https://home.openweathermap.org/users/sign_up';
    Uri urlToLaunch = Uri.parse(signUpUrl);
    try {
      await launchUrl(urlToLaunch);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Text('Use Yr API'),
            //     Switch(
            //       value: _useYrApi,
            //       onChanged: (value) {
            //         setState(() {
            //           _useYrApi = value;
            //         });
            //         _saveSettingsToDisk();
            //       },
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Svenska'),
                Switch(
                  value: _internationalLanguage,
                  onChanged: (value) {
                    setState(() {
                      _internationalLanguage = value;
                      _saveSettingsToDisk();
                    });
                  },
                ),
                Text('English')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Celsius, m/s, mm    '),
                Switch(
                  value: _imperialUnits,
                  onChanged: (value) {
                    setState(() {
                      _imperialUnits = value;
                      _saveSettingsToDisk();
                    });
                  },
                ),
                Text('Fahrenheit, mph, in')
              ],
            ),
            const Text('API Key to OpenWeatherMap'),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter API Key',
              ),
              onChanged: (value) {
                setState(() {
                  _apiKey = value;
                  _saveSettingsToDisk();
                });
              },
              obscureText: true,
              controller: TextEditingController(text: _apiKey),
            ),
            _internationalLanguage
                ? const Text(
                    'You can get an API key for free from OpenWeatherMap by signing up at https://openweathermap.org/api')
                : const Text(
                    'Du kan få en gratis API-nyckel från OpenWeatherMap genom att registrera dig på https://openweathermap.org/api'),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () async {
                  await _launchURL();
                },
                child: _internationalLanguage
                    ? const Text('Sign Up')
                    : const Text('Registrera'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                )),
          ],
        ));
  }
}
