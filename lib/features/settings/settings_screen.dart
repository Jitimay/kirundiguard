import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _ttsEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Kirundi';
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileCard(isDarkMode),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSettingsSection(
                          'Appearance',
                          Icons.palette_rounded,
                          isDarkMode,
                          [
                            _buildSwitchTile(
                              'Dark Mode',
                              'Switch between light and dark theme',
                              Icons.dark_mode_rounded,
                              isDarkMode,
                              (value) => context.read<ThemeCubit>().toggleTheme(),
                              isDarkMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsSection(
                          'Audio Settings',
                          Icons.volume_up_rounded,
                          isDarkMode,
                          [
                            _buildSwitchTile(
                              'Text-to-Speech',
                              'Enable voice reading of explanations',
                              Icons.record_voice_over_rounded,
                              _ttsEnabled,
                              (value) => setState(() => _ttsEnabled = value),
                              isDarkMode,
                            ),
                            _buildSliderTile(
                              'Speech Rate',
                              'Adjust reading speed',
                              Icons.speed_rounded,
                              _speechRate,
                              (value) => setState(() => _speechRate = value),
                              isDarkMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsSection(
                          'Language & Region',
                          Icons.language_rounded,
                          isDarkMode,
                          [
                            _buildDropdownTile(
                              'Primary Language',
                              'Choose your preferred language',
                              Icons.translate_rounded,
                              _selectedLanguage,
                              ['Kirundi', 'Swahili', 'English'],
                              (value) => setState(() => _selectedLanguage = value!),
                              isDarkMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsSection(
                          'Notifications',
                          Icons.notifications_rounded,
                          isDarkMode,
                          [
                            _buildSwitchTile(
                              'Push Notifications',
                              'Get notified about updates',
                              Icons.notifications_active_rounded,
                              _notificationsEnabled,
                              (value) => setState(() => _notificationsEnabled = value),
                              isDarkMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsSection(
                          'About',
                          Icons.info_rounded,
                          isDarkMode,
                          [
                            _buildActionTile(
                              'Privacy Policy',
                              'Read our privacy policy',
                              Icons.privacy_tip_rounded,
                              () => _showDialog('Privacy Policy', 'Your privacy is important to us...'),
                              isDarkMode,
                            ),
                            _buildActionTile(
                              'Terms of Service',
                              'View terms and conditions',
                              Icons.description_rounded,
                              () => _showDialog('Terms of Service', 'By using this app, you agree to...'),
                              isDarkMode,
                            ),
                            _buildActionTile(
                              'App Version',
                              'Version 1.0.0',
                              Icons.info_outline_rounded,
                              () {},
                              isDarkMode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.gradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Customize your experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, bool isDarkMode, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, IconData icon, double value, ValueChanged<double> onChanged, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
            divisions: 10,
            label: '${(value * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> items, ValueChanged<String?> onChanged, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        underline: Container(),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
