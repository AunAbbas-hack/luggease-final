import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'providers/app_state.dart';

void main() async {
  // Use runZonedGuarded to catch all global errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Ensure the app starts even if initialization takes time or fails
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 10));
      
      // Initialize notification service in background to not block startup
      unawaited(NotificationService.initialize().catchError((e) {
        debugPrint("Notification Initialization Error: $e");
      }));
    } catch (e) {
      debugPrint("Initialization Error: $e");
      // Still allow the app to run; individual services should handle their own errors
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const LuggEaseApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("Global Error: $error");
    debugPrint(stack.toString());
  });
}

class LuggEaseApp extends StatelessWidget {
  const LuggEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp.router(
          title: 'LuggEase',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRoutes.router,
          builder: (context, child) {
            // Global error boundary for UI
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        const Text(
                          "Something went wrong",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details.exceptionAsString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Go Back"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            };
            return child!;
          },
        );
      },
    );
  }
}
