import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/app_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.logoutFromApp();
              if (context.mounted) {
                context.go(AppRoutes.roleSelection);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings_rounded,
                  size: 64, color: AppConstants.primaryColor.withValues(alpha: 0.8)),
              const SizedBox(height: 24),
              Text(
                'Welcome${user?.name != null ? ', ${user!.name}' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Admin tools can be added here. Your account is stored under the Firestore "admins" collection.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppConstants.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
