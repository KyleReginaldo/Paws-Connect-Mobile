class Result<T> {
  final T? _value;
  final String? _error;

  Result.success([this._value]) : _error = null;
  Result.error([this._error]) : _value = null;

  bool get isSuccess => _value != null;
  bool get isError => _error != null;

  T get value => _value!;
  String get error => _error!;

  @override
  String toString() {
    return isSuccess ? 'Success($_value)' : 'Error($_error)';
  }
}
