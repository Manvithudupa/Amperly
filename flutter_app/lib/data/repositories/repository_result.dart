import '../../core/errors/user_messages.dart';

sealed class RepositoryResult<T> {
  const RepositoryResult();

  bool get isSuccess => this is RepositorySuccess<T>;

  T? get valueOrNull => switch (this) {
    RepositorySuccess<T>(:final T value) => value,
    RepositoryFailure<T>() => null,
  };

  RepositoryFailure<T>? get failureOrNull => switch (this) {
    RepositorySuccess<T>() => null,
    RepositoryFailure<T> failure => failure,
  };
}

final class RepositorySuccess<T> extends RepositoryResult<T> {
  const RepositorySuccess(this.value);

  final T value;
}

final class RepositoryFailure<T> extends RepositoryResult<T> {
  const RepositoryFailure({
    required this.kind,
    required this.message,
    this.cause,
  });

  final UserMessageKind kind;
  final String message;
  final Object? cause;

  factory RepositoryFailure.from(Object error, {int? httpStatus}) {
    final int? status = error is GeoapifyExceptionLike
        ? error.httpStatus ?? httpStatus
        : httpStatus;
    final UserMessageKind kind = UserMessages.classify(
      error,
      httpStatus: status,
    );
    return RepositoryFailure<T>(
      kind: kind,
      message: UserMessages.messageFor(kind),
      cause: error,
    );
  }
}

/// The small surface the repository boundary needs from a Geoapify failure.
abstract interface class GeoapifyExceptionLike {
  int? get httpStatus;
}
