import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/domain/useCases/useCase_result.dart';
import 'package:flutterapp/domain/useCases/useCase_update_event.dart';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'package:flutterapp/model/repositories/venue_repository_imp.dart';

enum UpdateEventState { initial, submitting, success, error }

class UpdateEventVm extends ChangeNotifier {
  final UpdateEventUseCase _updateEventUseCase;

  UpdateEventState _state = UpdateEventState.initial;
  String? _errorMessage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxCapacityController = TextEditingController();

  final Event originalEvent;

  Sport selectedSport;
  SkillLevel selectedSkillLevel;

  UpdateEventState get state => _state;
  String? get errorMessage => _errorMessage;

  List<Sport> get sports => Sport.values;
  List<SkillLevel> get skillLevels => SkillLevel.values;

  UpdateEventVm({required this.originalEvent})
      : _updateEventUseCase = UpdateEventUseCase(
    eventRepository: EventRepositoryImplementation(
      venueRepository: VenueRepositoryImplementation(),
    ),
  ),
        selectedSport = originalEvent.sport,
        selectedSkillLevel = originalEvent.skillLevel {
    nameController.text = originalEvent.name;
    descriptionController.text = originalEvent.description;
    maxCapacityController.text = originalEvent.maxCapacity.toString();
  }

  void onSportChanged(Sport? newSport) {
    if (newSport != null) {
      selectedSport = newSport;
      notifyListeners();
    }
  }

  void onSkillLevelChanged(SkillLevel? newSkillLevel) {
    if (newSkillLevel != null) {
      selectedSkillLevel = newSkillLevel;
      notifyListeners();
    }
  }

  Future<void> updateEvent(BuildContext context) async {
    if (nameController.text.isEmpty || maxCapacityController.text.isEmpty) {
      _showPopup(context, "Please fill all editable fields.", isError: true);
      return;
    }

    _setSubmitting(true);

    try {
      final updatedEvent = originalEvent.copyWith(
        name: nameController.text,
        description: descriptionController.text,
        maxCapacity: int.parse(maxCapacityController.text),
        sport: selectedSport,
        skillLevel: selectedSkillLevel,

      );

      final UseCaseResult result = await _updateEventUseCase.execute(updatedEvent);

      if (result.success) {
        _state = UpdateEventState.success;
        _showPopup(context, "Event updated successfully!", onDismiss: () {
          Navigator.of(context).pop(true);
        });
      } else {
        _showPopup(context, result.errorMessage ?? "An unknown error occurred.", isError: true);
      }
    } catch (e) {
      _showPopup(context, "An invalid value was provided for capacity.", isError: true);
    } finally {
      _setSubmitting(false);
    }
  }

  void _setSubmitting(bool isSubmitting) {
    _state = isSubmitting ? UpdateEventState.submitting : UpdateEventState.initial;
    notifyListeners();
  }

  void _showPopup(BuildContext context, String message, {bool isError = false, VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isError ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.check_mark_circled_solid,
                color: isError ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 10),
              Text(isError ? "Error" : "Success"),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    maxCapacityController.dispose();
    super.dispose();
  }
}

