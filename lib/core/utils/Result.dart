import 'package:find_job_app/core/error/Failures.dart';

/// Lightweight Either-like wrapper so repositories don't need to throw
/// across layer boundaries.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    return failure((self as Failed<T>).failure);
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failed<T> extends Result<T> {
  final Failure failure;
  const Failed(this.failure);
}
