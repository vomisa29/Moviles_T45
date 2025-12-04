import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/user.dart';
import 'package:flutterapp/model/repositories/booked_repository_imp.dart';
import 'package:flutterapp/model/repositories/user_repository_imp.dart';

class AttendeesListVm extends ChangeNotifier {
  final String eventId;

  final BookedEventRepositoryImplementation _bookedRepo;
  final UserRepositoryImplementation _userRepo;

  bool _loading = true;
  List<User> _attendees = [];
  String? _error;

  bool get isLoading => _loading;
  List<User> get attendees => _attendees;
  String? get error => _error;

  AttendeesListVm({required this.eventId})
      : _bookedRepo = BookedEventRepositoryImplementation(),
        _userRepo = UserRepositoryImplementation() {
    _fetchAttendees();
  }

  Future<void> _fetchAttendees() async {
    try {
      _loading = true;
      notifyListeners();

      final bookings = await _bookedRepo.getBookingsForEvent(eventId);
      final userIds = bookings.map((booking) => booking.userId).toList();

      if (userIds.isEmpty) {
        _attendees = [];
      } else {
        final List<User> userList = [];
        for (final userId in userIds) {
          final user = await _userRepo.getOne(userId);
          if (user != null) {
            userList.add(user);
          }
        }
        _attendees = userList;
      }

      _error = null;
    } catch (e) {
      _error = "Failed to load attendees.";
      debugPrint("Error fetching attendees: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
