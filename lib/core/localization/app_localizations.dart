import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'about_us': 'About Us',
      'contact_us': 'Contact Us',
      'profile': 'Profile',
      'settings': 'Settings',
      'download': 'Download',
      'login': 'Login',
      'register': 'Register',
      'update': 'Update',
      'history': 'History',
      'logout': 'Logout',
      'language': 'Language',
      'home': 'Home',
      'dark_mode': 'Dark Mode',
      'email': 'Email',
      'password': 'Password',
      'enter_email': 'Enter email',
      'invalid_email': 'Invalid email',
      'enter_password': 'Enter password',
      'password_too_short': 'Password too short',
      'dont_have_account': "Don't have an account? Sign up",
      'create_account': 'Create Account',
      'confirm_password': 'Confirm Password',
      'passwords_dont_match': "Passwords don't match",
      'sign_up': 'Sign Up',
      'already_have_account': 'Already have an account? Login',
    },
    'ki': {
      'about_us': 'IBITURANGA',
      'contact_us': 'Twandikire',
      'profile': 'Ibindanga/umwidondoro',
      'settings': 'kuregera',
      'download': 'Voma/kwega',
      'login': 'KWINJIRA',
      'register': 'Kwiyandikisha',
      'update': 'Shira kugihe',
      'history': 'ivyakozwe',
      'logout': 'Gusohoka',
      'language': 'Ururimi',
      'home': 'Ahabanza',
      'dark_mode': 'Uburyo bw’ijoro',
      'email': 'Imeli',
      'password': 'Ijambo banga',
      'enter_email': 'Shiramwo imeli',
      'invalid_email': 'Imeli siyo',
      'enter_password': 'Shiramwo ijambo banga',
      'password_too_short': 'Ijambo banga rigufi cane',
      'dont_have_account': "Nta konte ufise? Iyandikishe",
      'create_account': 'Kora konte',
      'confirm_password': 'Emeza ijambo banga',
      'passwords_dont_match': "Amajambo banga ntahuye",
      'sign_up': 'Iyandikishe',
      'already_have_account': 'Ufise konte? Injira',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ki'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
