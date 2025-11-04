extension ObjectExtension on Object {
  T? asA<T>() {
    if (this is T) {
      return this as T;
    }
    return null;
  }
}
