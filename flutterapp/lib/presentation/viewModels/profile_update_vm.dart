import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/models/user.dart';
import '../../domain/useCases/useCase_update_profile.dart';
import '../../domain/useCases/useCase_result.dart';


class ProfileUpdateVm extends ChangeNotifier {
  final UpdateProfileUseCase _updateProfileUseCase;

  final TextEditingController usernameController;
  final TextEditingController sportsController;
  final TextEditingController descriptionController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final User _initialUser;

  ProfileUpdateVm(this._initialUser)
      : _updateProfileUseCase = UpdateProfileUseCase(),
        usernameController = TextEditingController(text: _initialUser.username),
        sportsController = TextEditingController(text: _initialUser.sportList?.join(', ')),
        descriptionController = TextEditingController(text: _initialUser.description);

  Future<void> updateUser(BuildContext context) async {
    if (usernameController.text.trim().isEmpty) {
      _showPopup(context, "Username cannot be empty.", isError: true);
      return;
    }

    _setLoading(true);

    final updatedUser = User(
      uid: _initialUser.uid,
      email: _initialUser.email,
      role: _initialUser.role,
      username: usernameController.text,
      description: descriptionController.text,
      sportList: sportsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      avgRating: _initialUser.avgRating,
      numRating: _initialUser.numRating,
      assistanceRate: _initialUser.assistanceRate,
      createdAt: _initialUser.createdAt,
      avatarUrl: _initialUser.avatarUrl,
    );

    final result = await _updateProfileUseCase.execute(
      updatedUser: updatedUser,
      originalUsername: _initialUser.username,
    );

    _setLoading(false);

    if (result.success) {
      _showPopup(context, "Profile updated successfully!", onDismiss: () {
        context.pop(true);
      });
    } else {
      _showPopup(context, result.errorMessage ?? "An unknown error occurred.", isError: true);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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
    usernameController.dispose();
    sportsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
