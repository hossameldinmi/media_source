/// URI helper extensions used by the package.
///
/// Adds convenient accessors for extracting file-related information from
/// `Uri` instances.
extension UriExtensions on Uri {
  /// Returns the base name of the URI path (e.g., 'video.mp4').
  ///
  /// Splits the path by '/' and returns the last segment.
  String get fileName => path.split('/').last;
}
