import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'platform_impl/platform_utils_io.dart' if (dart.library.js_interop) 'platform_impl/platform_utils_web.dart';

/// Platform-specific utilities used throughout the package.
///
/// Exposes a single `instance` accessor which delegates to a platform
/// implementation selected via conditional imports (IO vs web).
///
/// Use `PlatformUtils.instance` to perform file and directory operations
/// in a platform-agnostic way.
class PlatformUtils {
  static final _instance = PlatformUtilsFacadeImpl();
  static PlatformUtilsFacade get instance => _instance;
}

/// Facade interface implemented by platform-specific utilities.
///
/// Implementations must provide safe, asynchronous file and directory
/// operations suitable for the runtime platform (native IO or web).
abstract class PlatformUtilsFacade {
  /// Deletes the given [XFile] from the underlying platform storage.
  ///
  /// Returns `true` when deletion succeeds, `false` otherwise.
  Future<bool> deleteFile(XFile file);

  /// Ensures the parent directory of [filePath] exists, creating it if needed.
  ///
  /// [filePath] is the path of a file about to be written; the directory that
  /// will contain it is created recursively when missing.
  Future<void> ensureParentDirectoryExists(String filePath);

  /// Ensures the parent directory of [directoryPath] exists.
  @Deprecated('Despite its name, this creates the parent directory of the given path, '
      'not the directory itself. Use ensureParentDirectoryExists instead.')
  Future<void> createDirectoryIfNotExists(String directoryPath) => ensureParentDirectoryExists(directoryPath);

  /// Moves the file at [sourcePath] to [destinationPath] using a fast
  /// platform rename when available.
  ///
  /// Returns `false` when the platform cannot rename (e.g. web, cross-device
  /// moves, missing source); callers should fall back to copy + delete.
  Future<bool> moveFile(String sourcePath, String destinationPath);

  /// Returns `true` if the directory exists.
  ///
  /// Marked `@visibleForTesting` because consumers should prefer the
  /// higher-level operations; exposed mainly to support unit tests.
  @visibleForTesting
  Future<bool> directoryExists(String directoryPath);

  /// Deletes the directory at [directoryPath] recursively.
  ///
  /// Marked `@visibleForTesting` for test helpers that need to clean up.
  @visibleForTesting
  Future<bool> deleteDirectory(String directoryPath);

  /// Returns `true` if the given [XFile] refers to an existing resource on
  /// the underlying platform (file system or web blob etc.).
  Future<bool> fileExists(XFile xFile);
}
