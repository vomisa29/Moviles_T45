import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/models/user.dart';
import 'viewModels/profile_update_vm.dart';

class ProfileUpdateView extends StatelessWidget {
  final User user;
  const ProfileUpdateView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileUpdateVm(user),
      child: Consumer<ProfileUpdateVm>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCFBF8),
            body: Stack(
              children: [
                _buildForm(context, vm),
                if (vm.isLoading) _buildLoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProfileUpdateVm vm) {
    final theme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 16),
            Text(
              "Configure Profile",
              style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              vm.usernameController,
              label: "Username",
              hint: "Enter username",
            ),
            const SizedBox(height: 24),
            _buildTextField(
              vm.sportsController,
              label: "Sports",
              hint: "Enter sports, separated by commas",
            ),
            const SizedBox(height: 24),
            _buildTextField(
              vm.descriptionController,
              label: "Description",
              hint: "",
              maxLines: 5,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38B480),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () => vm.updateUser(context),
                child: const Text("Update Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, {
        required String label,
        required String hint,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Updating user...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),

      ),
    );
  }
}
