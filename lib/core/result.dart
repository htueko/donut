sealed class Failure {
  const Failure();
}

final class NetworkFailure extends Failure {
  const NetworkFailure([this.message]);
  final String? message;
}

final class CacheFailure extends Failure {
  const CacheFailure([this.message]);
  final String? message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure([this.message]);
  final String? message;
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([this.message]);
  final String? message;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error, [this.stack]);
  final Object error;
  final StackTrace? stack;
}

sealed class Result<T> {
  const Result();

  bool get isFailure => this is FailureResult<T>;

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    FailureResult<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };

  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Success<R>(transform(value)),
      FailureResult<T>(:final failure) => FailureResult<R>(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
