// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:web/web.dart' as web;

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
  Future<void> ensureDirectoryExists(String directoryPath) {
    return Future.value();
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
}
