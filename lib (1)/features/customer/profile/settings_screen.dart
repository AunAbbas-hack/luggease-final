import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("App Settings"),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  return Column(
                    children: [
                      SwitchListTile(
                        value: appState.notificationsEnabled,
                        onChanged: (v) => appState.toggleNotifications(v),
                        title: const Text("Push Notifications", style: TextStyle(color: Colors.white, fontSize: 16)),
                        secondary: const Icon(Icons.notifications_active_outlined, color: AppConstants.primaryColor),
                        activeColor: AppConstants.primaryColor,
                      ),
                      const Divider(color: Colors.white10, indent: 16, endIndent: 16),
                      SwitchListTile(
                        value: appState.isDarkMode,
                        onChanged: (v) => appState.toggleDarkMode(v),
                        title: const Text("Dark Mode", style: TextStyle(color: Colors.white, fontSize: 16)),
                        secondary: const Icon(Icons.dark_mode_outlined, color: AppConstants.primaryColor),
                        activeColor: AppConstants.primaryColor,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Account & Privacy"),
            const SizedBox(height: 16),
            _buildSettingsList([
              _buildSettingsTile(Icons.lock_outline, "Privacy Policy", () {}),
              _buildSettingsTile(Icons.description_outlined, "Terms of Service", () {}),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader("Support"),
            const SizedBox(height: 16),
            _buildSettingsList([
              _buildSettingsTile(Icons.help_outline, "Help & Support", () {}),
              _buildSettingsTile(Icons.info_outline, "About LuggEase", () {}),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    "LuggEase",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Version 1.0.0 (Build 1)",
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppConstants.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingsList(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppConstants.primaryColor, size: 22),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          onTap: onTap,
        ),
      ],
    );
  }
}
