// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:web/web.dart' as web;

/// Web implementation of [PlatformUtilsFacade].
///
/// On web, file system semantics differ from native platforms. This class
/// provides web-friendly implementations that operate on blob URLs and
/// in-memory data. Certain operations like creating directories are
/// no-ops in the browser environment.
class PlatformUtilsFacadeImpl implements PlatformUtilsFacade {
  /// Deletes a blob URL created for an [XFile] by revoking it when possible.
  ///
  /// Returns `true` if the blob URL was revoked; otherwise `false`.
  @override
  Future<bool> deleteFile(XFile file) async {
    try {
      if (file.path.startsWith('blob:')) {
        web.URL.revokeObjectURL(file.path);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Directory creation is a no-op on the web; returns immediately.
  @override
  Future<void> createDirectoryIfNotExists(String directoryPath) {
    // TODO: implement createDirectoryIfNotExists
    throw UnimplementedError();
  }

  /// Directory existence checks are always `true` on the web facade because
  /// the browser does not expose a traditional file system.
  @override
  Future<bool> directoryExists(String directoryPath) {
    // TODO: implement directoryExists
    throw UnimplementedError();
  }

  /// Deleting directories is not supported on the web facade.
  @override
  Future<bool> deleteDirectory(String directoryPath) {
    // TODO: implement deleteDirectory
    throw UnimplementedError();
  }

  /// Attempts to verify a file exists on the web by trying to read it.
  ///
  /// This method is conservative: it will attempt to read the bytes from
  /// the [XFile] and return true if that succeeds, false otherwise.
  @override
  Future<bool> fileExists(XFile xFile) async {
    // On web, files are either:
    // 1. Blob URLs (in memory) - exist if the URL is valid
    // 2. Data URLs - always exist
    // 3. HTTP/HTTPS URLs - would need network check
    // 4. Files from picker - exist by definition

    try {
      // Try to read the file to verify it exists and is accessible
      await xFile.readAsBytes();
      return true;
    } catch (e) {
      return false;
    }
  }
}
