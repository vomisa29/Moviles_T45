class UseCaseResult {
  final bool success;
  final String? errorMessage;
  final Object? data;
  const UseCaseResult({required this.success, this.errorMessage, this.data});
}