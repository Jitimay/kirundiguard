import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kirundiguard/core/localization/app_localizations.dart';
import 'bloc/auth_bloc.dart';
import '../../core/theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/new_icon.png', height: 120),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.translate('create_account'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.translate('email'),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.translate('enter_email');
                                if (!value!.contains('@')) return AppLocalizations.of(context)!.translate('invalid_email');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.translate('password'),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.translate('enter_password');
                                if (value!.length < 6) return AppLocalizations.of(context)!.translate('password_too_short');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.translate('confirm_password'),
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return AppLocalizations.of(context)!.translate('passwords_dont_match');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            BlocConsumer<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state is AuthError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message)),
                                  );
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading ? null : _signUp,
                                    child: state is AuthLoading
                                        ? const CircularProgressIndicator()
                                        : Text(AppLocalizations.of(context)!.translate('sign_up')),
                                  ),
                                );
                              },
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.translate('already_have_account')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpRequested(_emailController.text, _passwordController.text),
      );
    }
  }
}
