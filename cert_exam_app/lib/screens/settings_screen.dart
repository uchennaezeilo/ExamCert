import 'package:flutter/material.dart';
import 'package:cert_exam_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              return SwitchListTile(
                title: Text(mode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
                value: mode == ThemeMode.dark,
                onChanged: (val) async {
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_dark_mode', val);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}