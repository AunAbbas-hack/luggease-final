import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/theme/app_colors.dart';

class AddLuggageScreen extends StatefulWidget {
  const AddLuggageScreen({super.key});

  @override
  State<AddLuggageScreen> createState() => _AddLuggageScreenState();
}

class _AddLuggageScreenState extends State<AddLuggageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _flightController = TextEditingController();
  final _destinationController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _flightController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Register Luggage')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luggage Details',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the information below to track your bag.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Nickname',
                hint: 'e.g. My Blue Suitcase',
                controller: _nicknameController,
                icon: Icons.label_important_outline,
              ),
              _buildTextField(
                label: 'Flight Number',
                hint: 'e.g. EK202',
                controller: _flightController,
                icon: Icons.flight_takeoff_outlined,
              ),
              _buildTextField(
                label: 'Destination',
                hint: 'e.g. London (LHR)',
                controller: _destinationController,
                icon: Icons.place_outlined,
              ),
              _buildTextField(
                label: 'Estimated Weight',
                hint: 'e.g. 22.5 kg',
                controller: _weightController,
                icon: Icons.monitor_weight_outlined,
              ),
              const SizedBox(height: 40),
              CustomButton(
                label: 'Add Luggage',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      await FirebaseFirestore.instance
                          .collection('luggage')
                          .add({
                            'userId': user.uid,
                            'nickname': _nicknameController.text,
                            'flightNumber': _flightController.text,
                            'destination': _destinationController.text,
                            'weight': _weightController.text,
                            'status': 'checkedIn',
                            'lastUpdated': DateTime.now().toIso8601String(),
                          });

                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      context.pop();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Luggage added successfully!'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: Icon(icon, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter $label' : null,
          ),
        ],
      ),
    );
  }
}
