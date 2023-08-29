import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {
  bool _internationalLanguage = false;
  bool _imperialUnits = false;
  bool _useYrApi = false;
  String _apiKey = '';

  bool get internationalLanguage => _internationalLanguage;
  bool get imperialUnits => _imperialUnits;
  bool get useYrApi => _useYrApi;
  String get apiKey => _apiKey;

  void updateSettings({
    bool? internationalLanguage,
    bool? imperialUnits,
    bool? useYrApi,
    String? apiKey,
  }) {
    _internationalLanguage = internationalLanguage ?? _internationalLanguage;
    _imperialUnits = imperialUnits ?? _imperialUnits;
    _useYrApi = useYrApi ?? _useYrApi;
    _apiKey = apiKey ?? _apiKey;
    notifyListeners();
  }
}
