/// Exception bertipe supaya UI bisa menampilkan pesan yang tepat per jenis
/// kegagalan (dibedakan dari step mana yang gagal di alur upload, lihat
/// `providers/upload_flow_controller.dart`).
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Tidak ada koneksi internet.']);
}

class ApiException extends AppException {
  const ApiException(this.statusCode, super.message);
  final int statusCode;

  bool get isAuthError => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isServerError => statusCode >= 500;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Terjadi kesalahan yang tidak diketahui.']);
}
