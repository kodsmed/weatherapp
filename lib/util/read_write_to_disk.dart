import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> saveNonSensitiveDataToDisk(
    bool internationalLanguage, bool imperialUnits, bool useYrApi) async {
  final preferens = await SharedPreferences.getInstance();
  preferens.setBool('internationalLanguage', internationalLanguage);
  preferens.setBool('imperialUnits', imperialUnits);
  preferens.setBool('useYrApi', useYrApi);
}

Future<Map<String,bool>> loadNonSensitiveSettings() async {
  final preferens = await SharedPreferences.getInstance();
  return {
    'internationalLanguage': preferens.getBool('internationalLanguage') ?? false,
    'imperialUnits': preferens.getBool('imperialUnits') ?? false,
    'useYrApi': preferens.getBool('useYrApi') ?? false,
  };
}


final _storage = FlutterSecureStorage();

Future<void> saveSensitiveSettings(String apiKey) async {
  await _storage.write(key: 'codeSmith_WeatherApp_apiKey', value: apiKey);
}

Future<String?> loadSensitiveSettings() async {
  return await _storage.read(key: 'codeSmith_WeatherApp_apiKey');
}

