import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  static const _cacheKey = 'create_event_form_cache';
  final CacheManager _cacheManager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 1,
    ),
  );

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

  Timer? _debounce;

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
    nameController.addListener(_onFieldChanged);
    descriptionController.addListener(_onFieldChanged);
    maxCapacityController.addListener(_onFieldChanged);
    startTimeController.addListener(_onFieldChanged);
    endTimeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      saveToCache();
    });
  }

  Future<void> _loadVenues() async {
    _state = CreateEventState.loading;
    notifyListeners();

    try {
      _venues = await _venueRepository.getAll();
      if (_venues.isNotEmpty) {
        selectedVenue = _venues.first;
      }
      await _loadFromCache();
      _state = CreateEventState.ready;
    } catch (e) {
      _state = CreateEventState.error;
    }
    notifyListeners();
  }

  Future<void> _loadFromCache() async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(_cacheKey);
      if (fileInfo == null || !await fileInfo.file.exists()) return;

      final jsonString = await fileInfo.file.readAsString();
      if (jsonString.isEmpty) return;

      final formData = jsonDecode(jsonString) as Map<String, dynamic>;

      nameController.text = formData['name'] ?? '';
      descriptionController.text = formData['description'] ?? '';
      maxCapacityController.text = formData['maxCapacity'] ?? '';
      startTimeController.text = formData['startTime'] ?? '';
      endTimeController.text = formData['endTime'] ?? '';

      final sportName = formData['sport'];
      if (sportName != null) {
        selectedSport = Sport.values.firstWhere((s) => s.name == sportName);
      }

      final skillLevelName = formData['skillLevel'];
      if (skillLevelName != null) {
        selectedSkillLevel = SkillLevel.values.firstWhere((s) => s.name == skillLevelName);
      }

      final venueId = formData['venueId'];
      if (venueId != null && _venues.isNotEmpty) {
        selectedVenue = _venues.firstWhere((v) => v.id == venueId, orElse: () => _venues.first);
      }
    } catch (e) {
      debugPrint("Could not load form cache: $e");
    }
  }

  Future<void> saveToCache() async {
    final formData = {
      'name': nameController.text,
      'description': descriptionController.text,
      'maxCapacity': maxCapacityController.text,
      'startTime': startTimeController.text,
      'endTime': endTimeController.text,
      'sport': selectedSport?.name,
      'skillLevel': selectedSkillLevel?.name,
      'venueId': selectedVenue?.id,
    };
    final jsonString = jsonEncode(formData);
    final fileBytes = utf8.encode(jsonString);
    await _cacheManager.putFile(_cacheKey, fileBytes);
    debugPrint("CreateEventVm: Form data auto-saved to cache.");
  }

  Future<void> _clearCache() async {
    await _cacheManager.removeFile(_cacheKey);
  }

  void onVenueChanged(Venue? newVenue) {
    selectedVenue = newVenue;
    saveToCache();
    notifyListeners();
  }

  void onSportChanged(Sport? newSport) {
    selectedSport = newSport;
    saveToCache();
    notifyListeners();
  }

  void onSkillLevelChanged(SkillLevel? newSkillLevel) {
    selectedSkillLevel = newSkillLevel;
    saveToCache();
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
        await _clearCache();
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
    if (_venues.isNotEmpty) {
      selectedVenue = _venues.first;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    nameController.removeListener(_onFieldChanged);
    descriptionController.removeListener(_onFieldChanged);
    maxCapacityController.removeListener(_onFieldChanged);
    startTimeController.removeListener(_onFieldChanged);
    endTimeController.removeListener(_onFieldChanged);

    nameController.dispose();
    descriptionController.dispose();
    maxCapacityController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
