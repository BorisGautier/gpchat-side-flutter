import 'package:gpchat/Services/localization/demo_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: todo
//TODO:---- All localizations settings----
const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String FRENCH = 'fr';

//--
List languagelist = [
  ENGLISH,
  FRENCH,
];
List<Locale> supportedlocale = [
  Locale(ENGLISH, "US"),
  Locale(FRENCH, "FR"),
];

Future<Locale> setLocale(String languageCode) async {
  print(languageCode);
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  print(LAGUAGE_CODE);
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "fr";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');

    case FRENCH:
      return Locale(FRENCH, 'FR');

    default:
      return Locale(FRENCH, 'FR');
  }
}

String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key) ?? '';
}
