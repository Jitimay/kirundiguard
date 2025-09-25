import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/services/ai_service.dart';
import 'core/services/storage_service.dart';
import 'features/ocr/bloc/ocr_bloc.dart';
import 'features/explain/bloc/explain_bloc.dart';
import 'features/history/bloc/history_bloc.dart';
import 'features/navigation/main_navigation.dart';

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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
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
            return MaterialApp(
              title: 'IkirundiGuard',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const MainNavigation(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
