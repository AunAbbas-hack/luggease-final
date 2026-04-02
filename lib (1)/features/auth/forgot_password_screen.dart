import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleReset() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.push('/check-email');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Forgot Password?",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 12),
            Text(
              "Enter your registered email or phone to reset your password",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 60),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Email or Phone Number",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.textSecondary),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "e.g. name@email.com",
                    suffixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleReset,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Send Recovery Link"),
                        SizedBox(width: 12),
                        Icon(Icons.send_rounded, size: 20),
                      ],
                    ),
                  ),
            const SizedBox(height: 200),
            TextButton(
              onPressed: () => context.pop(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_back, size: 16, color: AppConstants.textSecondary),
                  SizedBox(width: 8),
                  Text("Return to Login", style: TextStyle(color: AppConstants.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
