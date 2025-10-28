import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app/auth_notifier.dart';
import 'package:provider/provider.dart';

import '../model/models/event.dart';
import '../model/models/venue.dart';
import 'viewModels/create_event_vm.dart';

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateEventVm(),
      child: Consumer<CreateEventVm>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCFBF8),
            body: Stack(
              children: [
                _buildBody(context, vm),
                if (vm.state == CreateEventState.loading || vm.state == CreateEventState.submitting)
                  _buildLoadingOverlay(vm.state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CreateEventVm vm) {
    final theme = Theme.of(context).textTheme;
    final authNotifier = context.read<AuthNotifier>();

    if (vm.state == CreateEventState.error) {
      return const Center(
          child: Text("Could not load creation form.", style: TextStyle(color: Colors.red)));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),
            Text(
              "Create Event",
              style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildTextField(vm.nameController, label: "Event Name", hint: "e.g., Morning Football Match"),
            const SizedBox(height: 24),
            _buildTextField(vm.descriptionController, label: "Description", hint: "Describe your event...", maxLines: 4),
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
            _buildDropdown<Venue>(
              label: "Venue",
              value: vm.selectedVenue,
              items: vm.venues.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
              onChanged: vm.onVenueChanged,
            ),
            const SizedBox(height: 24),
            _buildTextField(vm.maxCapacityController, label: "Max Participants", hint: "e.g., 22", keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _buildDateTimePicker(context, vm.startTimeController, "Start Time"),
            const SizedBox(height: 24),
            _buildDateTimePicker(context, vm.endTimeController, "End Time"),
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
                onPressed: () {
                  final organizerId = authNotifier.user?.uid;
                  if (organizerId != null) {
                    vm.createEvent(context, organizerId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You must be logged in to create an event."), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text("Create Event"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    controller.text = dateTime.toIso8601String();
    (context as Element).markNeedsBuild();
  }

  Widget _buildDateTimePicker(BuildContext context, TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select date and time',
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(CupertinoIcons.calendar),
          ),
          onTap: () => _selectDateTime(context, controller),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, {
        required String label,
        required String hint,
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
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

  Widget _buildDropdown<T>(
      {required String label, T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
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

  Widget _buildLoadingOverlay(CreateEventState state) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            const SizedBox(height: 16),
            if(state == CreateEventState.submitting)
              const Text("Creating event...", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
