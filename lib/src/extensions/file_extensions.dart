import 'dart:async';
import 'package:cross_file/cross_file.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:file_sized/file_sized.dart';

/// Convenience extensions for [XFile] used by this package.
///
/// Provides platform-agnostic helpers such as deletion via the package's
/// [PlatformUtils] facade, size extraction as a [FileSize], and media type
/// detection.
extension FileExtensions on XFile {
  /// Deletes the underlying file/resource using the platform facade.
  ///
  /// On native platforms this will delete the file from disk. On web it may
  /// revoke blob URLs if applicable. Returns `true` when deletion succeeded.
  Future<bool> delete() async {
    if (await exists()) return PlatformUtils.instance.deleteFile(this);
    return false;
  }

  /// Returns the file size wrapped in a [FileSize].
  ///
  /// Uses the cross-file `length()` and converts to a [FileSize] for
  /// convenient human-readable formatting elsewhere in the package.
  Future<FileSize> size() => length().then((v) => v.b);

  /// Returns `true` when the underlying file/resource exists on the
  /// platform (disk, blob URL, etc.).
  Future<bool> exists() => PlatformUtils.instance.fileExists(this);

  /// Attempts to detect the media type of the file.
  ///
  /// On web, detection is done from the bytes; on native platforms it's done
  /// from the file path and/or mime type.
  Future<FileType> getMediaType([String? media]) async =>
      kIsWeb ? FileType.fromBytes(await readAsBytes(), mimeType) : FileType.fromPath(path, mimeType);
}
