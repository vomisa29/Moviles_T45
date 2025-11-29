// FULL CORRECTED CODE

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/presentation/viewModels/main_view_vm.dart';
import 'package:flutterapp/presentation/viewModels/update_event_vm.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateEventView extends StatelessWidget {
  final Event event;
  const UpdateEventView({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateEventVm(originalEvent: event),
      child: const UpdateEventViewBody(),
    );
  }
}

class UpdateEventViewBody extends StatelessWidget {
  const UpdateEventViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdateEventVm>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF8),
      body: Stack(
        children: [
          _buildForm(context, vm),
          if (vm.state == UpdateEventState.submitting) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, UpdateEventVm vm) {
    final theme = Theme.of(context).textTheme;
    // Get connectivity status from the globally provided MainViewVm
    final isConnected = context.watch<MainViewVm>().isConnected;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            Text(
              "Edit Event",
              style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // --- Editable Fields ---
            _buildTextField(vm.nameController, label: "Event Name"),
            const SizedBox(height: 24),
            _buildTextField(vm.descriptionController, label: "Description", maxLines: 4),
            const SizedBox(height: 24),
            _buildDropdown<Sport>(
              label: "Sport",
              value: vm.selectedSport,
              items: vm.sports.map((s) => DropdownMenuItem(value: s, child: Text(sportToString(s)))).toList(),
              onChanged: vm.onSportChanged,
            ),
            const SizedBox(height: 24),
            _buildDropdown<SkillLevel>(
              label: "Skill Level",
              value: vm.selectedSkillLevel,
              items: vm.skillLevels.map((s) => DropdownMenuItem(value: s, child: Text(skillToString(s)))).toList(),
              onChanged: vm.onSkillLevelChanged,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              vm.maxCapacityController,
              label: "Max Participants",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40), // Increased spacing after the last field

            // --- Read-Only Fields for Venue and Time have been REMOVED ---

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? const Color(0xFF38B480) : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: isConnected ? () => vm.updateEvent(context) : null,
                child: const Text("Update Event"),
              ),
            ),
            if (!isConnected)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    "Internet connection required to update the event.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {required String label, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
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

  Widget _buildDropdown<T>(
      {required String label,
        T? value,
        required List<DropdownMenuItem<T>> items,
        required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
              "Updating Event...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
