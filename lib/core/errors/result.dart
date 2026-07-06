class Failure {
  final String message;
  const Failure(this.message);
}

class Result<T> {
  final T? data;
  final Failure? failure;

  Result._({this.data, this.failure});
  Result.success(T value) : this._(data: value);
  Result.error(String message) : this._(failure: Failure(message));

  bool get isSuccess => failure == null;
}
