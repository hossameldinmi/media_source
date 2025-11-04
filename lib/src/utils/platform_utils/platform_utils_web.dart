// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:web/web.dart' as web;
import 'package:flutter_media_metadata/flutter_media_metadata.dart' as metadata;

class PlatformUtilsFacadeImpl implements PlatformUtilsFacade {
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

  @override
  Future<void> createDirectoryIfNotExists(String directoryPath) {
    return Future.value();
  }

  @override
  Future<bool> directoryExists(String directoryPath) {
    return Future.value(true);
  }

  @override
  Future<bool> deleteDirectory(String directoryPath) {
    throw UnimplementedError();
  }

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

  @override
  Future<MediaMetadata?> getMediaMetadata(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    final result = await metadata.MetadataRetriever.fromBytes(bytes);
    return MediaMetadata(mimeType: result.mimeType, durationInMs: result.trackDuration);
  }

  @override
  Future<MediaMetadata?> getMediaMetadataFromBytes(Uint8List bytes, [String? fileName]) async {
    final result = await metadata.MetadataRetriever.fromBytes(bytes);
    return MediaMetadata(mimeType: result.mimeType, durationInMs: result.trackDuration);
  }
}
