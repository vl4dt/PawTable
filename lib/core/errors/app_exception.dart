/// Application exceptions for PawTable
class AppException implements Exception {
  final String message;
  final String code;

  const AppException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => '[$code] $message';
}

/// Common exception types
class NetworkException extends AppException {
  NetworkException({super.message = 'Network error occurred'})
    : super(code: 'network_error');
}

class AuthenticationException extends AppException {
  AuthenticationException({super.message = 'Authentication failed'})
    : super(code: 'auth_error');
}

class PermissionException extends AppException {
  PermissionException({super.message = 'Permission denied'})
    : super(code: 'permission_error');
}

class StorageException extends AppException {
  StorageException({super.message = 'Storage error occurred'})
    : super(code: 'storage_error');
}

class BillingException extends AppException {
  BillingException({super.message = 'Billing error occurred'})
    : super(code: 'billing_error');
}

class SyncException extends AppException {
  SyncException({super.message = 'Sync failed'})
    : super(code: 'sync_error');
}

/// Result type for error handling
enum ResultType { success, error }

class Result<T> {
  final T? data;
  final AppException? error;
  final ResultType type;

  const Result.success(this.data) : type = ResultType.success, error = null;
  const Result.failure(this.error) : type = ResultType.error, data = null;

  bool get isSuccess => type == ResultType.success;
  bool get isError => type == ResultType.error;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    }
    return failure(error as AppException);
  }
}
