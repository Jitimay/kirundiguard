import 'package:flutter/material.dart';

class FallbackMaterialLocalisationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(const Locale('en', ''));

  @override
  bool shouldReload(FallbackMaterialLocalisationsDelegate old) => false;
}
