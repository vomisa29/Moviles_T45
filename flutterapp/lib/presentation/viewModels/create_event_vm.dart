import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/useCases/useCase_create_event.dart';
import '../../domain/useCases/useCase_result.dart';
import '../../model/models/event.dart';
import '../../model/models/venue.dart';
import '../../model/repositories/event_repository_imp.dart';
import '../../model/repositories/user_repository_imp.dart';
import '../../model/repositories/venue_repository_imp.dart';

enum CreateEventState { loading, ready, submitting, error }

class CreateEventVm extends ChangeNotifier {
  final CreateEventUseCase _createEventUseCase;
  final VenueRepositoryImplementation _venueRepository;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxCapacityController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  CreateEventState _state = CreateEventState.loading;
  CreateEventState get state => _state;

  List<Venue> _venues = [];
  List<Venue> get venues => _venues;

  List<Sport> get sports => Sport.values;
  List<SkillLevel> get skillLevels => SkillLevel.values;

  Venue? selectedVenue;
  Sport? selectedSport;
  SkillLevel? selectedSkillLevel;

  CreateEventVm()
      : _venueRepository = VenueRepositoryImplementation(),
        _createEventUseCase = CreateEventUseCase(
          userRepository: UserRepositoryImplementation(),
          venueRepository: VenueRepositoryImplementation(),
          eventRepository: EventRepositoryImplementation(
            venueRepository: VenueRepositoryImplementation(),
          ),
        ) {
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    _state = CreateEventState.loading;
    notifyListeners();

    try {
      _venues = await _venueRepository.getAll();
      if (_venues.isNotEmpty) {
        selectedVenue = _venues.first;
      }
      _state = CreateEventState.ready;
    } catch (e) {
      _state = CreateEventState.error;
    }
    notifyListeners();
  }

  void onVenueChanged(Venue? newVenue) {
    selectedVenue = newVenue;
    notifyListeners();
  }

  void onSportChanged(Sport? newSport) {
    selectedSport = newSport;
    notifyListeners();
  }

  void onSkillLevelChanged(SkillLevel? newSkillLevel) {
    selectedSkillLevel = newSkillLevel;
    notifyListeners();
  }

  Future<void> createEvent(BuildContext context, String organizerId) async {
    if (nameController.text.isEmpty ||
        maxCapacityController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        selectedVenue == null ||
        selectedSport == null ||
        selectedSkillLevel == null) {
      _showPopup(context, "Please fill all fields.", isError: true);
      return;
    }

    _setSubmitting(true);

    try {
      final newEvent = Event(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        sport: selectedSport!,
        startTime: DateTime.parse(startTimeController.text),
        endTime: DateTime.parse(endTimeController.text),
        maxCapacity: int.parse(maxCapacityController.text),
        skillLevel: selectedSkillLevel!,
        venueId: selectedVenue!.id,
        organizerId: organizerId,
        assistanceRate: 0.0,
        booked: 0,
        assisted: 0,
        avgRating: 0.0,
        numRatings: 0,
      );

      final UseCaseResult result = await _createEventUseCase.execute(newEvent);
      _setSubmitting(false);

      if (result.success) {
        _showPopup(context, "Event created successfully!", onDismiss: () {
          clearForm();
        });
      } else {
        _showPopup(context, result.errorMessage ?? "An unknown error occurred.", isError: true);
      }
    } catch (e) {
      _setSubmitting(false);
      _showPopup(context, "An invalid value was provided. Check dates and capacity.", isError: true);
    }
  }

  void _setSubmitting(bool isSubmitting) {
    _state = isSubmitting ? CreateEventState.submitting : CreateEventState.ready;
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

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    maxCapacityController.clear();
    startTimeController.clear();
    endTimeController.clear();
    selectedSport = null;
    selectedSkillLevel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    maxCapacityController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
