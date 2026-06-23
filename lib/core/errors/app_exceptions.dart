sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class FirestoreException extends AppException {
  const FirestoreException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class MatchStateException extends AppException {
  const MatchStateException(super.message);
}

class InvalidZoneConsistencyException extends AppException {
  const InvalidZoneConsistencyException(super.message);
}
