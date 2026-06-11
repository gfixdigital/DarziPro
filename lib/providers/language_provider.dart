import 'package:flutter/material.dart';
import '../core/services/hive_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = HiveService.language;

  String get language => _language;
  bool get isUrdu => _language == 'ur';

  void setLanguage(String lang) {
    if (lang == _language) return;
    _language = lang;
    HiveService.language = lang;
    notifyListeners();
  }
}
