import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_cubit.dart';
import 'core/localization/fallback_material_localizations_delegate.dart';
import 'core/localization/fallback_cupertino_localizations_delegate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/services/ai_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
import 'features/ocr/bloc/ocr_bloc.dart';
import 'features/explain/bloc/explain_bloc.dart';
import 'screens/history/bloc/history_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.initialize();
  
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AiService>(
          create: (context) => AiService(),
        ),
        RepositoryProvider<StorageService>.value(
          value: storageService,
        ),
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider<LanguageCubit>(
            create: (context) => LanguageCubit(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthService>()),
          ),
          BlocProvider<OcrBloc>(
            create: (context) => OcrBloc(),
          ),
          BlocProvider<ExplainBloc>(
            create: (context) => ExplainBloc(
              context.read<AiService>(),
              context.read<StorageService>(),
            ),
          ),
          BlocProvider<HistoryBloc>(
            create: (context) => HistoryBloc(context.read<StorageService>()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, bool>(
          builder: (context, isDarkMode) {
            return BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  title: 'IkirundiGuard',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                  locale: locale,
                  home: const AuthWrapper(),
                  debugShowCheckedModeBanner: false,
                  supportedLocales: [
                    Locale('en', ''),
                    Locale('ki', ''),
                  ],
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    const FallbackMaterialLocalisationsDelegate(),
                    const FallbackCupertinoLocalisationsDelegate(),
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  localeResolutionCallback: (locale, supportedLocales) {
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale?.languageCode &&
                          supportedLocale.countryCode == locale?.countryCode) {
                        return supportedLocale;
                      }
                    }
                    return supportedLocales.first;
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
