import '../../model/models/user.dart';
import '../../model/serviceAdapters/auth_adapter.dart';
import '../../model/serviceAdapters/user_firestore_adapter.dart';
import 'useCase_result.dart';

class RegisterUseCase {
  final AuthService _authService;
  final UserFirestoreDs _userFirestoreDs;

  RegisterUseCase({
    AuthService? authService,
    UserFirestoreDs? userFirestoreDs,
  })  : _authService = authService ?? AuthService(),
        _userFirestoreDs = userFirestoreDs ?? UserFirestoreDs.instance;

  Future<UseCaseResult> execute({
    required String email,
    required String password,
  }) async {
    try {
      final firebaseUser = await _authService.createUserWithEmailAndPassword(email, password);

      if (firebaseUser == null) {
        return const UseCaseResult(
          success: false,
          errorMessage: "Could not create user account. The email might already be in use.",
        );
      }
      final newUser = User(
        uid: firebaseUser.uid,
        email: email,
        role: UserRole.user,
      );

      await _userFirestoreDs.create(newUser);
      return const UseCaseResult(success: true);

    } catch (e) {
      return UseCaseResult(
        success: false,
        errorMessage: "An unexpected error occurred during registration: $e",
      );
    }
  }
}
