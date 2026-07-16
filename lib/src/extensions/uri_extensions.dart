/// URI helper extensions used by the package.
///
/// Adds convenient accessors for extracting file-related information from
/// `Uri` instances.
extension UriExtensions on Uri {
  /// Returns the base name of the URI path (e.g., 'video.mp4').
  ///
  /// Uses the last non-empty path segment, percent-decoded (so
  /// `my%20video.mp4` becomes `my video.mp4`). Returns an empty string when
  /// the URI has no path (e.g. `https://example.com` or a trailing slash).
  String get fileName {
    for (var i = pathSegments.length - 1; i >= 0; i--) {
      if (pathSegments[i].isNotEmpty) return pathSegments[i];
    }
    return '';
  }
}
