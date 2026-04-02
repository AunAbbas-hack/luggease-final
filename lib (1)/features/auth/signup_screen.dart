import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Driver only controllers
  final _cnicController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // 1. Basic Form Validation
    if (!_formKey.currentState!.validate()) return;

    // 2. Custom Validations
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Email Regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError("Invalid email format. Please enter a valid email.");
      return;
    }

    // Phone Validation (basic length check)
    if (phone.length < 10) {
      _showError("Phone number format is incorrect.");
      return;
    }

    // Password Match
    if (password != confirmPassword) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);
    debugPrint("SignupScreen: Starting signup process");
    
    try {
      final userModel = await _authService.signup(
        name: _nameController.text.trim(),
        email: email,
        password: password,
        phone: phone,
        role: widget.role == 'driver' ? UserRole.driver : UserRole.customer,
        cnic: widget.role == 'driver' ? _cnicController.text.trim() : null,
        vehicleType: widget.role == 'driver' ? _vehicleTypeController.text.trim() : null,
        vehicleNumber: widget.role == 'driver' ? _vehicleNumberController.text.trim() : null,
      );

      debugPrint("SignupScreen: Signup API returned user: ${userModel?.uid}");

      if (userModel != null) {
        if (!mounted) return;
        
        debugPrint("SignupScreen: Updating AppState");
        Provider.of<AppState>(context, listen: false).setUser(userModel);
        
        debugPrint("SignupScreen: Navigating to dashboard for role: ${userModel.role}");
        if (userModel.role == UserRole.driver) {
          context.go('/driver-dashboard');
        } else {
          context.go('/customer-dashboard');
        }
      } else {
        debugPrint("SignupScreen: User model is null after signup");
        _showError("Signup failed. Please try again.");
      }
    } catch (e) {
      debugPrint("SignupScreen Error: $e");
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDriver = widget.role == 'driver';

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "LUGGEASE",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Container(height: 2, width: 12, color: AppConstants.primaryColor),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                "Fill in your details to get started as a ${widget.role}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildField("FULL NAME", "e.g. John Doe", _nameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildField("EMAIL ADDRESS", "hello@luggease.com", _emailController, Icons.email_outlined),
              const SizedBox(height: 20),
              _buildPasswordField("PASSWORD", _passwordController),
              const SizedBox(height: 20),
              _buildPasswordField("CONFIRM PASSWORD", _confirmPasswordController),
              const SizedBox(height: 20),
              _buildField("PHONE NUMBER", "+92 300 1234567", _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
              
              if (isDriver) ...[
                const SizedBox(height: 20),
                _buildField("CNIC NUMBER", "42101-XXXXXXX-X", _cnicController, Icons.badge_outlined),
                const SizedBox(height: 20),
                _buildField("VEHICLE TYPE", "e.g. Mini Truck, Pickup", _vehicleTypeController, Icons.local_shipping_outlined),
                const SizedBox(height: 20),
                _buildField("VEHICLE NUMBER", "e.g. ABC-123", _vehicleNumberController, Icons.tag),
              ],

              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?", style: TextStyle(color: AppConstants.textSecondary)),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text("Sign In", style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.textSecondary),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppConstants.primaryColor),
          ),
          validator: (v) => v!.trim().isEmpty ? 'Please fill this field' : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.textSecondary),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "••••••••",
            prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v!.isEmpty) return 'Please fill this field';
            if (v.length < 6) return 'Min 6 characters';
            return null;
          },
        ),
      ],
    );
  }
}
