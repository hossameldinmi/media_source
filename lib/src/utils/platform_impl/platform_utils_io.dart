import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:media_source/src/utils/platform_utils.dart';

/// IO implementation of the [PlatformUtilsFacade].
///
/// Provides concrete file system operations for native platforms (mobile,
/// desktop). All methods are written to be resilient: they catch exceptions
/// and return boolean success indicators where appropriate.
class PlatformUtilsFacadeImpl extends PlatformUtilsFacade {
  /// Deletes the provided [XFile] from disk.
  ///
  /// Returns `true` when deletion is successful, `false` otherwise.
  @override
  Future<bool> deleteFile(XFile file) async {
    try {
      if (!await fileExists(file)) return false;

      final fileToDelete = File(file.path);
      await fileToDelete.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Ensures the parent directory of [filePath] exists; creates it if missing.
  @override
  Future<void> ensureParentDirectoryExists(String filePath) async {
    final directory = Directory(filePath).parent;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// Moves the file with [File.rename]; falls back to `false` when renaming
  /// fails (e.g. cross-device moves) so callers can copy + delete instead.
  @override
  Future<bool> moveFile(String sourcePath, String destinationPath) async {
    try {
      final source = File(sourcePath);
      if (sourcePath.isEmpty || !await source.exists()) return false;
      await source.rename(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Returns `true` when the directory exists on disk.
  ///
  /// Visible for testing to allow unit tests to verify environment state.
  @override
  @visibleForTesting
  Future<bool> directoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    return directory.exists();
  }

  /// Deletes the directory recursively; returns `true` on success.
  ///
  /// Visible for testing to allow test teardown of created resources.
  @override
  @visibleForTesting
  Future<bool> deleteDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) return false;

      directory.deleteSync(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Returns `true` if the file exists on disk.
  @override
  Future<bool> fileExists(XFile file) async {
    try {
      final path = file.path;
      if (path.isEmpty) return false; // If path is empty, the file cannot exist
      return File(path).exists();
    } catch (e) {
      return false;
    }
  }
}
