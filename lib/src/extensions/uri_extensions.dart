extension UriExtensions on Uri {
  String get fileName => path.split('/').last;
}
