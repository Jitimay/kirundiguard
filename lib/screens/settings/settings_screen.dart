import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kirundiguard/core/localization/app_localizations.dart';
import 'package:kirundiguard/core/localization/language_cubit.dart';
import 'package:kirundiguard/core/theme/theme_cubit.dart';
import 'package:kirundiguard/features/auth/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.translate('language')),
                BlocBuilder<LanguageCubit, Locale>(
                  builder: (context, locale) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButton<String>(
                        value: locale.languageCode,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            context.read<LanguageCubit>().changeLanguage(newValue);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'ki',
                            child: Text('Kirundi'),
                          ),
                        ],
                        underline: const SizedBox(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.translate('dark_mode')),
                BlocBuilder<ThemeCubit, bool>(
                  builder: (context, isDarkMode) {
                    return Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                child: Text(AppLocalizations.of(context)!.translate('logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}