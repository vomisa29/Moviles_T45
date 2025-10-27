import '../../model/models/user.dart';
import '../../model/repositories/user_repository_imp.dart';
import 'useCase_result.dart';
import 'dart:developer';

class UpdateProfileUseCase {
  final UserRepositoryImplementation _userRepository;

  static final UpdateProfileUseCase _instance = UpdateProfileUseCase._internal();
  factory UpdateProfileUseCase() => _instance;

  UpdateProfileUseCase._internal({UserRepositoryImplementation? userRepository})
      : _userRepository = userRepository ?? UserRepositoryImplementation();

  Future<UseCaseResult> execute({
    required User updatedUser,
    required String? originalUsername,
  }) async {
    try {
      if (updatedUser.username != null && updatedUser.username != originalUsername) {
        final existingUser = await _userRepository.getUserByUsername(updatedUser.username!);

        if (existingUser!= null) {
          return UseCaseResult(
            success: false,
            errorMessage: "The username '${updatedUser.username}' is already taken!",
          );
        }
      }

      await _userRepository.update(updatedUser);
      return const UseCaseResult(success: true);

    } catch (e, stackTrace) {
      log(
        'An error occurred in UpdateProfileUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return const UseCaseResult(
        success: false,
        errorMessage: "There was an error. Try again later.",
      );
    }
  }
}
